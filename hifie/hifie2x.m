% HIFIE2X       Hierarchical interpolative factorization for integral operators
%               in 2D with accuracy optimizations for second-kind integral
%               equations.
%
%    F = HIFIE2X(A,X,OCC,RANK_OR_TOL,PXYFUN) produces a factorization F of the
%    interaction matrix A on the points X using tree occupancy parameter OCC,
%    local precision parameter RANK_OR_TOL, and proxy function PXYFUN to capture
%    the far field. This is a function of the form
%
%      [KPXY,NBR] = PXYFUN(X,SLF,NBR,L,CTR)
%
%    that is called for every block, where
%
%      - KPXY: interaction matrix against artificial proxy points
%      - NBR:  block neighbor indices (can be modified)
%      - X:    input points
%      - SLF:  block indices
%      - L:    block size
%      - CTR:  block center
%
%    See the examples for further details. If PXYFUN is not provided or empty
%    (default), then the code uses the naive global compression scheme.
%
%    F = HIFIE2X(A,X,OCC,RANK_OR_TOL,PXYFUN,OPTS) also passes various options to
%    the algorithm. Valid options include:
%
%      - LVLMAX: maximum tree depth (default: LVLMAX = Inf).
%
%      - SKIP: skip the dimension reductions on the first SKIP levels (default:
%              SKIP = 0).
%
%      - SYMM: assume that the matrix is unsymmetric if SYMM = 'N', (complex-)
%              symmetric if SYMM = 'S', and Hermitian if SYMM = 'H' (default:
%              SYMM = 'N'). If SYMM = 'N' or 'S', then local factors are
%              computed using the LU decomposition; if SYMM = 'H', then these
%              are computed using the LDL decomposition.
%
%      - VERB: display status of the code if VERB = 1 (default: VERB = 0).
%
%    References:
%
%      E. Corona, P.-G. Martinsson, D. Zorin. An O(N) direct solver for
%        integral equations on the plane. arXiv:1303.5466, 2013.
%
%      K.L. Ho, L. Ying. Hierarchical interpolative factorization for elliptic
%        operators: integral equations. arXiv:1307.2666, 2013.
%
%    See also HIFIE2, HIFIE3, HIFIE3X, HIFIE_MV, HIFIE_SV, HYPOCT, ID.

function F = hifie2x(A,x,occ,rank_or_tol,pxyfun,opts)
  start = tic;

  % set default parameters
  if nargin < 5
    pxyfun = [];
  end
  if nargin < 6
    opts = [];
  end
  if ~isfield(opts,'lvlmax')
    opts.lvlmax = Inf;
  end
  if ~isfield(opts,'skip')
    opts.skip = 0;
  end
  if ~isfield(opts,'symm')
    opts.symm = 'n';
  end
  if ~isfield(opts,'verb')
    opts.verb = 0;
  end
  spdir = Inf;

  % check inputs
  opts.symm = lower(opts.symm);
  if opts.skip < 0
    error('FLAM:hifie2x:negativeSkip','Skip parameter must be nonnegative.')
  end
  if ~(strcmp(opts.symm,'n') || strcmp(opts.symm,'s') || strcmp(opts.symm,'h'))
    error('FLAM:hifie2x:invalidSymm', ...
          'Symmetry parameter must be one of ''N'', ''S'', or ''H''.')
  end

  % build tree
  N = size(x,2);
  tic
  t = hypoct(x,occ,opts.lvlmax);

  % print summary
  if opts.verb
    fprintf(['-'*ones(1,80) '\n'])
    fprintf(' %3s  | %63.2e (s)\n','-',toc)
  end

  % count nonempty boxes at each level
  pblk = zeros(t.nlvl+1,1);
  for lvl = 1:t.nlvl
    pblk(lvl+1) = pblk(lvl);
    for i = t.lvp(lvl)+1:t.lvp(lvl+1)
      if ~isempty(t.nodes(i).xi)
        pblk(lvl+1) = pblk(lvl+1) + 1;
      end
    end
  end

  % initialize
  mn = t.lvp(end);
  e = cell(mn,1);
  F = struct('sk',e,'rd',e,'T',e,'E',e,'F',e,'P',e,'L',e,'U',e);
  F = struct('N',N,'nlvl',0,'lvp',zeros(1,2*t.nlvl+1),'factors',F,'symm', ...
             opts.symm);
  nlvl = 0;
  n = 0;
  rem = true(N,1);
  mnz = 128;
  M = sparse(N,N);
  I = zeros(mnz,1);
  J = zeros(mnz,1);
  S = zeros(mnz,1);
  Q = zeros(N,1);

  % loop over tree levels
  for lvl = t.nlvl:-1:1
    l = t.lrt/2^(lvl - 1);
    nbox = t.lvp(lvl+1) - t.lvp(lvl);

    % pull up skeletons from children
    for i = t.lvp(lvl)+1:t.lvp(lvl+1)
      t.nodes(i).xi = [t.nodes(i).xi [t.nodes(t.nodes(i).chld).xi]];
    end

    % loop over dimensions
    for d = [2 1]
      tic

      % dimension reduction
      if d < 2

        % continue if in skip stage
        if lvl > t.nlvl - opts.skip
          continue
        end

        % generate edge centers
        ctr = zeros(4*nbox,2);
        box2ctr = cell(nbox,1);
        for i = t.lvp(lvl)+1:t.lvp(lvl+1)
          j = i - t.lvp(lvl);
          idx = 4*(j-1)+1:4*j;
          off = [0 -1; -1  0; 0 1; 1 0];
          ctr(idx,:) = bsxfun(@plus,t.nodes(i).ctr,0.5*l*off);
          box2ctr{j} = idx;
        end

        % find unique shared centers
        idx = round(2*ctr/l);
        [~,i,j] = unique(idx,'rows');
        idx(:) = 0;
        p = find(histc(j,1:max(j)) > 1);
        i = i(p);
        idx(p) = 1:length(p);
        ctr = ctr(i,:);
        for box = 1:nbox
          box2ctr{box} = nonzeros(idx(j(box2ctr{box})))';
        end
        nb = size(ctr,1);
        e = cell(nb,1);
        blocks = struct('ctr',e,'xi',e,'prnt',e,'nbr1',e,'nbr2',e);

        % sort points by centers
        for box = 1:nbox
          xi = [t.nodes(t.lvp(lvl)+box).xi];
          i = box2ctr{box};
          dx = bsxfun(@minus,x(1,xi),ctr(i,1));
          dy = bsxfun(@minus,x(2,xi),ctr(i,2));
          dist = sqrt(dx.^2 + dy.^2);
          near = bsxfun(@eq,dist,min(dist,[],1));
          for i = 1:length(xi)
            Q(xi(i)) = box2ctr{box}(find(near(:,i),1));
          end
        end
        for box = 1:nbox
          xi = [t.nodes(t.lvp(lvl)+box).xi];
          if ~isempty(xi)
            m = histc(Q(xi),1:nb);
            p = cumsum(m);
            p = [0; p(:)];
            [~,idx] = sort(Q(xi));
            xi = xi(idx);
            for j = box2ctr{box}
              blocks(j).xi = [blocks(j).xi xi(p(j)+1:p(j+1))];
              blocks(j).prnt = [blocks(j).prnt (t.lvp(lvl)+box)*ones(1,m(j))];
            end
          end
        end

        % keep only nonempty centers
        m = histc(Q(rem),1:nb);
        idx = m > 0;
        ctr = ctr(idx,:);
        blocks = blocks(idx);
        nb = length(blocks);
        for i = 1:nb
          blocks(i).ctr = ctr(i,:);
        end
        p = cumsum(m == 0);
        for box = 1:nbox
          box2ctr{box} = box2ctr{box}(idx(box2ctr{box}));
          box2ctr{box} = box2ctr{box} - p(box2ctr{box})';
        end

        % find neighbors for each center
        proc = zeros(nb,1);
        for box = 1:nbox
          j = t.nodes(t.lvp(lvl)+box).nbor;
          j = j(j <= t.lvp(lvl));
          for i = box2ctr{box}
            blocks(i).nbr1 = [blocks(i).nbr1 j];
          end
          slf = box2ctr{box};
          nbr = t.nodes(t.lvp(lvl)+box).nbor;
          nbr = nbr(nbr > t.lvp(lvl)) - t.lvp(lvl);
          nbr = unique([box2ctr{[box nbr]}]);
          dx = abs(round(bsxfun(@minus,ctr(slf,1),ctr(nbr,1)')/l));
          dy = abs(round(bsxfun(@minus,ctr(slf,2),ctr(nbr,2)')/l));
          nrx = bsxfun(@le,dx,1);
          nry = bsxfun(@le,dy,1);
          near = nrx & nry;
          for i = 1:length(slf)
            j = slf(i);
            if ~proc(j)
              k = nbr(near(i,:));
              blocks(j).nbr2 = k(k ~= j);
              proc(j) = 1;
            end
          end
        end
      end

      % initialize
      nlvl = nlvl + 1;
      if d == 2
        nb = t.lvp(lvl+1) - t.lvp(lvl);
      else
        nb = length(blocks);
        for i = t.lvp(lvl)+1:t.lvp(lvl+1)
          t.nodes(i).xi = [];
        end
      end
      nblk = pblk(lvl) + nb;
      nrem1 = sum(rem);
      nz = 0;

      % loop over blocks
      for i = 1:nb
        if d == 2
          j = t.lvp(lvl) + i;
          blk = t.nodes(j);
          nbr = [t.nodes(blk.nbor).xi];
        else
          blk = blocks(i);
          nbr = [[t.nodes(blk.nbr1).xi] [blocks(blk.nbr2).xi]];
        end
        slf = blk.xi;
        nslf = length(slf);
        sslf = sort(slf);

        % compute proxy interactions and subselect neighbors
        Kpxy = zeros(0,nslf);
        if lvl > 2
          if isempty(pxyfun)
            nbr = setdiff(find(rem),slf);
          else
            [Kpxy,nbr] = pxyfun(x,slf,nbr,l,blk.ctr);
          end
        end

        % add neighbors with modified interactions
        [mod,~] = find(M(:,slf));
        mod = unique(mod);
        mod = mod(~ismembc(unique(mod),sslf));
        nbr = unique([nbr(:); mod(:)]);
        nnbr = length(nbr);
        snbr = sort(nbr);

        % compute interaction matrices
        K1 = full(A(nbr,slf));
        if strcmp(opts.symm,'n')
          K1 = [K1; full(A(slf,nbr))'];
        end
        if nlvl > spdir
          K2 = full(M(nbr,slf));
          if strcmp(opts.symm,'n')
            K2 = [K2; full(M(slf,nbr))'];
          end
        else
          K2 = spget('nbr','slf');
          if strcmp(opts.symm,'n')
            K2 = [K2; spget('slf','nbr')'];
          end
        end
        K = [K1 + K2; Kpxy];

        % scale compression tolerance
        if rank_or_tol < 1
          nrm1 = snorm(nslf,@(x)(K1*x),@(x)(K1'*x));
          if nnz(K2) > 0
            nrm2 = snorm(nslf,@(x)(K2*x),@(x)(K2'*x));
          else
            nrm2 = 0;
          end
          ratio = min(1,nrm1/nrm2);
        else
          ratio = 1;
        end

        % partition by sparsity structure of modified interactions
        K2 = K2(logical(sum(abs(K2),2)),:);
        if nnz(K2) == 0
          grp = {1:nslf};
          ngrp = 1;
        else
          Kmod = K2 ~= 0;
          Kmod = bsxfun(@rdivide,Kmod,sqrt(sum(Kmod.^2)));
          R = Kmod'*Kmod;
          Krem = ones(nslf,1);
          grp = cell(nslf,1);
          ngrp = 0;
          s = 0.5*(1 + sqrt(1 - 1/size(K2,1)));
          for k = 1:nslf
            if Krem(k)
              idx = find(R(:,k) > s);
              if any(idx)
                ngrp = ngrp + 1;
                grp{ngrp} = idx;
                Krem(idx) = 0;
              end
            end
          end
          if any(Krem)
            ngrp = ngrp + 1;
            grp{ngrp} = find(Krem);
          end
          grp = grp(1:ngrp);
        end

        % skeletonize by partition
        sk_ = cell(ngrp,1);
        rd_ = cell(ngrp,1);
        T_ = cell(ngrp,1);
        psk = zeros(ngrp,1);
        prd = zeros(ngrp,1);
        for k = 1:ngrp
          K_ = K(:,grp{k});
          Kpxy_ = Kpxy(:,grp{k});
          [sk_{k},rd_{k},T_{k}] = id([K_; Kpxy_],ratio*rank_or_tol);
          psk(k) = length(sk_{k});
          prd(k) = length(rd_{k});
        end

        % reassemble skeletonization
        psk = [0; cumsum(psk(:))];
        prd = [0; cumsum(prd(:))];
        sk = zeros(1,psk(end));
        rd = zeros(1,prd(end));
        T = zeros(psk(end),prd(end));
        for k = 1:ngrp
          sk(psk(k)+1:psk(k+1)) = grp{k}(sk_{k});
          rd(prd(k)+1:prd(k+1)) = grp{k}(rd_{k});
          T(psk(k)+1:psk(k+1),prd(k)+1:prd(k+1)) = T_{k};
        end

        % restrict to skeletons
        if d == 2
          t.nodes(j).xi = slf(sk);
        else
          for j = sk
            t.nodes(blk.prnt(j)).xi = [t.nodes(blk.prnt(j)).xi slf(j)];
          end
        end
        rem(slf(rd)) = 0;

        % move on if no compression
        if isempty(rd)
          continue
        end

        % compute factors
        if nlvl > spdir
          K = full(A(slf,slf)) + full(M(slf,slf));
        else
          K = full(A(slf,slf)) + spget('slf','slf');
        end
        if strcmp(opts.symm,'n') || strcmp(opts.symm,'h')
          K(rd,:) = K(rd,:) - T'*K(sk,:);
        elseif strcmp(opts.symm,'s')
          K(rd,:) = K(rd,:) - T.'*K(sk,:);
        end
        K(:,rd) = K(:,rd) - K(:,sk)*T;
        if strcmp(opts.symm,'n') || strcmp(opts.symm,'s')
          [L,U,P] = lu(K(rd,rd));
          X = U\(L\P);
        elseif strcmp(opts.symm,'h')
          [L,U,P] = ldl(K(rd,rd));
          X = P*(L'\(U\(L\P')));
        end
        E = K(sk,rd)*X;
        if strcmp(opts.symm,'n')
          G = X*K(rd,sk);
        elseif strcmp(opts.symm,'s') || strcmp(opts.symm,'h')
          G = [];
        end

        % update self-interaction
        S_ = -K(sk,rd)*X*K(rd,sk);
        [I_,J_] = ndgrid(slf(sk));
        m = length(sk)^2;
        while mnz < nz + m
          e = zeros(mnz,1);
          I = [I; e];
          J = [J; e];
          S = [S; e];
          mnz = 2*mnz;
        end
        I(nz+1:nz+m) = I_(:);
        J(nz+1:nz+m) = J_(:);
        S(nz+1:nz+m) = S_(:);
        nz = nz + m;

        % store matrix factors
        n = n + 1;
        while mn < n
          e = cell(mn,1);
          s = struct('sk',e,'rd',e,'T',e,'E',e,'F',e,'P',e,'L',e,'U',e);
          F.factors = [F.factors; s];
          mn = 2*mn;
        end
        F.factors(n).sk = slf(sk);
        F.factors(n).rd = slf(rd);
        F.factors(n).T = T;
        F.factors(n).E = E;
        F.factors(n).F = G;
        F.factors(n).P = P;
        F.factors(n).L = L;
        F.factors(n).U = U;
      end
      F.lvp(nlvl+1) = n;

      % update modified entries
      if nlvl > spdir
        idx = find(rem);
        [I_,J_,S_] = find(M(idx,idx));
        I_ = idx(I_);
        J_ = idx(J_);
      else
        [I_,J_,S_] = find(M);
        idx = rem(I_) & rem(J_);
        I_ = I_(idx);
        J_ = J_(idx);
        S_ = S_(idx);
      end
      m = length(S_);
      while mnz < nz + m
        e = zeros(mnz,1);
        I = [I; e];
        J = [J; e];
        S = [S; e];
        mnz = 2*mnz;
      end
      I(nz+1:nz+m) = I_;
      J(nz+1:nz+m) = J_;
      S(nz+1:nz+m) = S_;
      nz = nz + m;
      M = sparse(I(1:nz),J(1:nz),S(1:nz),N,N);

      % print summary
      if opts.verb
        nrem2 = sum(rem);
        fprintf('%3d-%1d | %6d | %8d | %8d | %8.2f | %8.2f | %10.2e (s)\n', ...
                lvl,d,nblk,nrem1,nrem2,nrem1/nblk,nrem2/nblk,toc)
      end
      if nblk == 1
        break
      end
    end
  end

  % finish
  F.nlvl = nlvl;
  F.lvp = F.lvp(1:nlvl+1);
  F.factors = F.factors(1:n);
  if opts.verb
    fprintf(['-'*ones(1,80) '\n'])
    toc(start)
  end

  % sparse matrix access function (native MATLAB is slow for large matrices)
  function A = spget(Ityp,Jtyp)
    if strcmp(Ityp,'slf')
      I_ = slf;
      nI = nslf;
      I_sort = sslf;
    elseif strcmp(Ityp,'nbr')
      I_ = nbr;
      nI = nnbr;
      I_sort = snbr;
    end
    if strcmp(Jtyp,'slf')
      J_ = slf;
      nJ = nslf;
    elseif strcmp(Jtyp,'nbr')
      J_ = nbr;
      nJ = nnbr;
    end
    Q(I_) = 1:nI;
    A = zeros(nI,nJ);
    [I_,J_,S_] = find(M(:,J_));
    idx = ismembc(I_,I_sort);
    I_ = I_(idx);
    J_ = J_(idx);
    S_ = S_(idx);
    if nI == 1
      S_ = S_';
    end
    idx = Q(I_) + (J_ - 1)*nI;
    A(idx) = A(idx) + S_;
  end
end
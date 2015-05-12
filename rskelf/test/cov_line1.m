% Squared exponential covariance function on the unit line.

function cov_line1(n,occ,p,rank_or_tol,noise,scale)

  % set default parameters
  if nargin < 1 || isempty(n)
    n = 16384;
  end
  if nargin < 2 || isempty(occ)
    occ = 64;
  end
  if nargin < 3 || isempty(p)
    p = 8;
  end
  if nargin < 4 || isempty(rank_or_tol)
    rank_or_tol = 1e-12;
  end
  if nargin < 5 || isempty(noise)
    noise = 1e-2;
  end
  if nargin < 6 || isempty(scale)
    scale = 100;
  end

  % initialize
  x = (1:n)/n;
  N = size(x,2);
  proxy = linspace(1.5,2.5,p);
  proxy = [-proxy proxy];

  % factor matrix
  opts = struct('symm','p','verb',1);
  F = rskelf(@Afun,x,occ,rank_or_tol,@pxyfun,opts);
  w = whos('F');
  fprintf([repmat('-',1,80) '\n'])
  fprintf('mem: %6.2f (MB)\n',w.bytes/1e6)

  % set up FFT multiplication
  a = Afun(1:n,1);
  B = zeros(2*n-1,1);
  B(1:n) = a;
  B(n+1:end) = flipud(a(2:n));
  G = fft(B);

  % test accuracy using randomized power method
  X = rand(N,1);
  X = X/norm(X);

  % NORM(A - F)/NORM(A)
  tic
  rskelf_mv(F,X);
  t = toc;
  [e,niter] = snorm(N,@(x)(mv(x) - rskelf_mv(F,x)),[],[],1);
  e = e/snorm(N,@mv,[],[],1);
  fprintf('mv: %10.4e / %4d / %10.4e (s)\n',e,niter,t)

  % NORM(INV(A) - INV(F))/NORM(INV(A)) <= NORM(I - A*INV(F))
  tic
  rskelf_sv(F,X);
  t = toc;
  [e,niter] = snorm(N,@(x)(x - mv(rskelf_sv(F,x))),[],[],1);
  fprintf('sv: %10.4e / %4d / %10.4e (s)\n',e,niter,t)

  % NORM(F - C*C')/NORM(F)
  tic
  rskelf_cholmv(F,X);
  t = toc;
  [e,niter] = snorm(N,@(x)(rskelf_mv(F,x) ...
                         - rskelf_cholmv(F,rskelf_cholmv(F,x,'c'))),[],[],1);
  e = e/snorm(N,@(x)(rskelf_mv(F,x)),[],[],1);
  fprintf('cholmv: %10.4e / %4d / %10.4e (s)\n',e,niter,t)

  % NORM(INV(F) - INV(C')*INV(C))/NORM(INV(F))
  tic
  rskelf_cholsv(F,X);
  t = toc;
  [e,niter] = snorm(N,@(x)(rskelf_sv(F,x) ...
                         - rskelf_cholsv(F,rskelf_cholsv(F,x),'c')),[],[],1);
  e = e/snorm(N,@(x)(rskelf_sv(F,x)),[],[],1);
  fprintf('cholsv: %10.4e / %4d / %10.4e (s)\n',e,niter,t)

  % compute log-determinant
  tic
  ld = rskelf_logdet(F);
  t = toc;
  fprintf('logdet: %22.16e / %10.4e (s)\n',ld,t)

  % kernel function
  function K = Kfun(x,y)
    dr = scale*abs(bsxfun(@minus,x',y));
    K = exp(-0.5*dr.^2);
  end

  % matrix entries
  function A = Afun(i,j)
    A = Kfun(x(:,i),x(:,j));
    [I,J] = ndgrid(i,j);
    idx = I == J;
    A(idx) = A(idx) + noise^2;
  end

  % proxy function
  function [Kpxy,nbr] = pxyfun(x,slf,nbr,l,ctr)
    pxy = bsxfun(@plus,proxy*l,ctr');
    Kpxy = Kfun(pxy,x(slf));
  end

  % FFT multiplication
  function y = mv(x)
    y = ifft(G.*fft(x,2*n-1));
    y = y(1:n);
  end
end
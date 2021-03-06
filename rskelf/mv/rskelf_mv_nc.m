% RSKELF_MV_NC  Dispatch for RSKELF_MV with F.SYMM = 'N' and TRANS = 'C'.

function X = rskelf_mv_nc(F,X,mode)

  % initialize
  n = F.lvp(end);

  % upward sweep
  if bitget(mode,1)
    for i = 1:n
      sk = F.factors(i).sk;
      rd = F.factors(i).rd;
      X(sk,:) = X(sk,:) + F.factors(i).T*X(rd,:);
      X(rd,:) = F.factors(i).L'*X(rd(F.factors(i).p),:);
      X(rd,:) = X(rd,:) + F.factors(i).E'*X(sk,:);
    end
  end

  % downward sweep
  if bitget(mode,2)
    for i = n:-1:1
      sk = F.factors(i).sk;
      rd = F.factors(i).rd;
      X(sk,:) = X(sk,:) + F.factors(i).F'*X(rd,:);
      X(rd,:) = F.factors(i).U'*X(rd,:);
      X(rd,:) = X(rd,:) + F.factors(i).T'*X(sk,:);
    end
  end
end
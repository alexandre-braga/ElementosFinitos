function [shg, w] = shgGera(nen,nint)
  format long;
  %define pontos de integração e pesos
  switch (nint)
    %grau 1, 2 pts de integração
    case 2
      pt(1) = -sqrt(3)/3;
      pt(2) = sqrt(3)/3;
      w(1) = 1;
      w(2) = 1;
    %grau 2, 3 pts de integração
    case 3
      pt(1) = -sqrt(3/5);
      pt(2) = 0.0;
      pt(3) = sqrt(3/5);
      w(1) = 5/9;
      w(2) = 8/9;
      w(3) = 5/9;
    %grau 3, 4 pts de integração
    case 4
      pt(1) = -sqrt((3 + 2*sqrt(6/5))/7);
      pt(2) = -sqrt((3 - 2*sqrt(6/5))/7);
      pt(3) = sqrt((3 - 2*sqrt(6/5))/7);
      pt(4) = sqrt((3 + 2*sqrt(6/5))/7);
      w(1) = (18 - sqrt(30))/36;
      w(2) = (18 + sqrt(30))/36;
      w(3) = (18 + sqrt(30))/36;
      w(4) = (18 - sqrt(30))/36;
    case 5
      pt(1) = -1/3*sqrt(5 + 2*sqrt(10/7));
      pt(2) = -1/3*sqrt(5 - 2*sqrt(10/7));
      pt(3) = 0.0;
      pt(4) = 1/3*sqrt(5 - 2*sqrt(10/7));
      pt(5) = 1/3*sqrt(5 + 2*sqrt(10/7));
      w(1) = (322 - 13*sqrt(70))/900;
      w(2) = (322 + 13*sqrt(70))/900;
      w(3) = 128/225;
      w(4) = (322 + 13*sqrt(70))/900;
      w(5) = (322 - 13*sqrt(70))/900;
  endswitch
  %monta as funções de base
  for l = 1:nint
    t = pt(l);
    switch (nen)
      %grau 1
      case 2
        shg(1,1,l) = 0.5*(1.0 - t);
        shg(1,2,l) = 0.5*(1.0 + t);
        shg(2,1,l) = -1.0/2.0;
        shg(2,2,l) = 1.0/2.0;
      %grau 2
      case 3
        shg(1,1,l) = (t - 1.0)*t/2.0;
        shg(1,2,l) = -(t - 1.0)*(t + 1.0);
        shg(1,3,l) = (t + 1.0)*t/2.0;
        shg(2,1,l) = (2.0*t-1.0)/2.0;
        shg(2,2,l) = -2.0*t;
        shg(2,3,l) = (2.0*t+1.0)/2.0;
      %grau 3
      case 4
        shg(1,1,l) = -(9.0/16.0)*(t+1.0/3.0)*(t-1.0/3.0)*(t-1.0);
        shg(1,2,l) = (27.0/16.0)*(t+1.0)*(t-1.0/3.0)*(t-1.0);
        shg(1,3,l) = -(27.0/16.0)*(t+1.0)*(t+1.0/3.0)*(t-1.0);
        shg(1,4,l) = (9.0/16.0)*(t+1.0/3.0)*(t-1.0/3.0)*(t+1.0);
        shg(2,1,l) = -(3.0*t^2 - 2*t - 1)/16.0;
        shg(2,2,l) = (3.0*t^2 - 2*t - 1)*9.0/16.0;
        shg(2,3,l) = -(3.0*t^2 - 2*t - 1)*9.0/16.0;
        shg(2,4,l) = (3.0*t^2 - 2*t - 1)/16.0;
      %grau 4
      case 5
        shg(1,1,l) = (2.0/3.0)*(t+(1.0/2.0))*t*(t-(1.0/2.0))*(t-1.0);
        shg(1,2,l) = -(8.0/3.0)*(t-(1.0/2.0))*t*(t-1.0)*(t+1.0);
        shg(1,3,l) = 4.0*(t+1.0)*(t+(1.0/2.0))*(t-(1.0/2.0))*(t-1.0);
        shg(1,4,l) = -(8.0/3.0)*(t+(1.0/2.0))*t*(t-1.0)*(t+1.0);
        shg(1,5,l) = (2.0/3.0)*(t+(1.0/2.0))*t*(t-(1.0/2.0))*(t+1.0);
        shg(2,1,l) = (16.0*t^3 - 12.0*t^2 - 2*t + 1.0)/6.0;
        shg(2,2,l) = -(8.0*t^3 - 3.0*t^2 - 4.0*t + 1.0)*4.0/3.0;
        shg(2,3,l) = 16.0*t^3 - 10.0*t;
        shg(2,4,l) = -(8.0*t^3 + 3.0*t^2 - 4.0*t - 1.0)*4.0/3.0;
        shg(2,5,l) = (16.0*t^3 + 12.0*t^2 - 2*t - 1.0)/6.0;
    endswitch
  endfor 
endfunction

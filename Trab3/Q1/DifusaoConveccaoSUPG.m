clc
clear all
close all

format long;
%dominio
a = 0.0;
b = 1.0;
erro = zeros(4,1);
erroDer = zeros(4,1);
hh = zeros(4,1);

for grau = 1:1
  for cont = 1:3
    Kappa = 1.;
    E = 1.e-2;
    Peh = 1;
    if cont >=2
      Peh = 5;
      if cont >=3
        Peh = 10;
      endif
    endif
    Tau = coth(Peh) - 1/Peh;
    %tamanho do elemento
    hSUPG = (Peh*2*E)/abs(Kappa)
    %n de elementos
    nel = (b-a)/hSUPG
    %grau do polinomio de interpolação
    k = grau;
    %n de nós do elemento
    nen = k+1;
    %n de nós global
    np =  k*nel+1;
    %n de pontos de integração
    nint = nen;
    %matriz global de rigidez zerada
    K = zeros(np,np);
    %matriz global de convecção zerada
    C = zeros(np,np);
    %matriz global de difusao-convecção zerada
    KC = zeros(np,np);
    %vetor fonte zerado
    F = zeros(np,1);

    %montagem do xl !!!LINEAR!!!
    xlSUPG = zeros(np,1);
    xlSUPG(1) = a;
    for i = 2:np
      xlSUPG(i) = xlSUPG(i-1) + hSUPG/k;
    endfor

    %gera shg e pega as funções peso
    [shg, w]= shgGera(nen,nint);

    %montagem global
    for n = 1:nel
      for l = 1:nint
        xx = 0.;
        for i = 1:nen
          xx = xx + shg(1,i,l)*xlSUPG(k*(n-1)+i);
        endfor
        for j = 1:nen
          F(k*(n-1)+j) = F(k*(n-1)+j) + funcao(xx)*(shg(1,j,l) + Tau*Kappa*shg(2,j,l))*w(l)*hSUPG/2;
          for i = 1:nen
            K((k*(n-1)+i),(k*(n-1)+j)) = K((k*(n-1)+i),(k*(n-1)+j)) + funcaok(xx,E)*shg(2,i,l)*2/hSUPG*shg(2,j,l)*2/hSUPG*w(l)*hSUPG/2;
            %Para k=1 o termo de segunda derivada é anulado
            C((k*(n-1)+j),(k*(n-1)+i)) = C((k*(n-1)+j),(k*(n-1)+i)) + funcaoKappa(xx,Kappa)*shg(2,i,l)*2/hSUPG*(shg(1,j,l) + Tau*Kappa*shg(2,j,l))*w(l)*hSUPG/2;
          endfor
        endfor
      endfor
    endfor
    KC = K + C;
    
    %Condição de Dirichlet entrada
    KC(1,1) = 1;
    F(1) = 0;
    for i = 2:k+1
      F(i) = F(i) - (F(1)*KC(i,1));
      KC(1,i) = 0;
      KC(i,1) = 0;
    endfor
    
    %Condição de Dirichlet saida
    for i = np-(k+1):np
      F(i) = F(i) - (F(np)*KC(i,np));
      KC(np,i) = 0.;
      KC(i,np) = 0.;
    endfor
    KC(np,np) = 1;
    F(np) = 0;
    
    %função exata
    x = a;
    exata = zeros(np,1);
    for i = 1:np
      exata(i) = funcaoExata(x,E,Kappa);
      x += hSUPG/k;
    endfor  
    x = a:hSUPG/k:b;
    uSUPG = zeros(np);
    uSUPG = KC\F;
   
    %cálculo do erro derivada L2
    erdul2 = 0;
    for n = 1:nel
      erdu = 0;
      for l = 1:nint
        duh = 0;
        xx = 0;
        for i = 1:nen
          duh = duh + shg(2,i,l)*2/hSUPG*uSUPG(k*(n-1)+i);
          xx = xx + shg(1,i,l)*xlSUPG(k*(n-1)+i);
        endfor
        erdu = erdu + ((dfuncaoExata(xx,E,Kappa) - duh)**2) * w(l) * hSUPG/2;
       endfor
       erdul2 = erdul2 + erdu;
     endfor
    erdul2 = sqrt(erdul2);
    erroDer(cont) = erdul2;

    %cálculo do erro L2
    erul2 = 0;
    for n = 1:nel
      eru = 0;
      for l = 1:nint
        uh = 0;
        xx = 0;
        for i = 1:nen
          uh = uh + shg(1,i,l)*uSUPG(k*(n-1)+i);
          xx = xx + shg(1,i,l)*xlSUPG(k*(n-1)+i);
        endfor
        eru = eru + ((funcaoExata(xx,E,Kappa) - uh)**2) * w(l) * hSUPG/2;
      endfor
      erul2 = erul2 + eru;
    endfor
    erul2 = sqrt(erul2);
    erroSUPG(cont) = erul2;
    hhSUPG(cont) = hSUPG;
      
    %salva a resolucao
    nome = sprintf("log/PesosEPontosIntegracaoPehSUPG%dGrau%d.txt", Peh, grau);
    save(nome, 'xlSUPG', 'hSUPG', 'uSUPG', 'x', 'exata');
      
  endfor 
  
  %salva os erros
  nome = sprintf("log/ErrosSUPG%d.txt", grau);
  save(nome, 'erroSUPG', 'hhSUPG', 'erroDer');

endfor 

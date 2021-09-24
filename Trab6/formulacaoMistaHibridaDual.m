clc
clear all
close all

format long;
%dominio
a = 0.00;
b = 1.00;

delta1 = -1/2;
delta2 = 1/2;

beta0 = 10;
alfa = input('Insira o valor de alfa: ');

erro = zeros(4,1);   
hh = zeros(4,1);

for grau = 1:4
   for cont = 1:4
   nel = 4^cont;
   h = (b-a)/nel;
   k = grau;
   
   beta = k*k*beta0/h
   nen = k+1
   np =  k*nel+1;
   nint = k+1
      
   Lambda = zeros(nel+1);
   U = zeros(nel,2*nen);
   u = zeros(2*nen);
   %dar um split de u/U em U e P pois teremos u1,u2,p1,2 a cada 'u'

   elementosK = zeros(nel+1,nel+1);
   FkGlobal = zeros(nel+1,1);
      
   %montagem do xl
   xl = zeros(np,1);
   xl(1) = a;
   for i = 2:np
     xl(i) = xl(i-1) + h/k;
   endfor
      
   %gera shg e pega as funções peso
   [shg, w]= shgGera(nen,nint);
   [shge]= shgeGera(nen,nint);
      
   %Problema Global
   for n = 1:nel      
     Ak = zeros(2*nen,2*nen);
     Bk = zeros(2*nen,2);
     BTk = zeros(2,2*nen);
     Ck = zeros(2,2);
     Fk = zeros(2*nen,1);
        
     #parte integral de A e F no elemento
     for l = 1:nint
       xx = 0.;
       for j = 1:nen
         xx = xx + shg(1,j,l)*xl(k*(n-1)+j);
       endfor
       for i = 1:nen
         Fk(i) = Fk(i) + delta2*funcao(xx)*shg(2,i,l)*2/h*w(l)*h/2;
         Fk(nen+i) = Fk(nen+i) + funcao(xx)*shg(1,i,l)*w(l)*h/2;
         for j = 1:nen
           Ak(i,j) = Ak(i,j) + shg(2,j,l)*2/h*shg(2,i,l)*2/h*w(l)*h/2;
         endfor
       endfor
     endfor
        
     #Calcula B, A , BT, C pra cada elemento
     for i = 1:nen
       Bk(i,1) += shge(2,i,1)*2/h + beta*shge(1,i,1);
       Bk(i,2) += shge(2,i,2)*2/h - beta*shge(1,i,2);
       for j = 1:nen
         Ak(i,j) += 
         %PHI J PHI I 
         (shge(1,j,2)*2/h*shge(1,i,2) - shge(1,j,1)*2/h*shge(1,i,1))
         %PSI j PHI i'
         -(shge(1,j,2)*2/h*shge(2,i,2) - shge(1,j,1)*2/h*shge(2,i,1))
         %PHI j' PSI i
         -(shge(2,j,2)*2/h*shge(1,i,2) - shge(2,j,1)*2/h*shge(1,i,1))
         %(PHI j + PSI j')(PHI i + PSHI j')
         +delta1()
         %PHI j' PHI i'
         +delta2(shge(2,j,2)*2/h*shge(2,i,2) - shge(2,j,1)*2/h*shge(2,i,1))
         %PSI j PSI i - PSI j PSI i
         +beta(shge(1,j,2)*2/h*shge(1,i,2) - shge(1,j,1)*2/h*shge(1,i,1))
         %posicionar corretamente relacionando u, p com phi e psi corretamente
         %conferir com o posicionamento na formulacao dual
         %colocar a parte integral na parte do codigo certa
         Ak(nen+i,j) +=
         Ak(i,nen+j) +=
         Ak(nen+i,nen+j) +=
        endfor
     endfor

     for j = 1:nen
       BTk(1,j) += - shge(2,j,1)*2/h + beta*shge(1,j,1);
       BTk(2,j) += shge(2,j,2)*2/h - beta*shge(1,j,2);
     endfor
     Ck(1,1) = -beta;
     Ck(2,2) = beta;
        
     if alfa == -1
       BTk = transpose(Bk);
     endif
     
     #calcula K e F elemento
     elementoK = zeros(2,2);
     elementoK = Ck - BTk*inverse(Ak)*Bk;
     Fkk = zeros(2,1);
     Fkk = -BTk*inverse(Ak)*Fk;
        
     #armazena como global o elemento

     for i = 1:2
       FkGlobal((n-1)+i) += Fkk(i);
       for j = 1:2
         elementosK((n-1)+i,(n-1)+j) += elementoK(i,j);
       endfor
     endfor
   endfor
     
   %Condição de Dirichlet entrada
   elementosK(1,1) = 1.;
   FkGlobal(1) = funcaoExata(a);
   for i = 2:k+1
     FkGlobal(i) = FkGlobal(i) - (FkGlobal(1)*elementosK(i,1));
     elementosK(1,i) = 0.;
     elementosK(i,1) = 0.;
   endfor
        
   %Condição de Dirichlet saida
   FkGlobal(nel+1) = funcaoExata(b);
   for i = nel+1-k:nel+1
     FkGlobal(i) = FkGlobal(i) - (FkGlobal(nel+1)*elementosK(i,nel+1));
     elementosK(nel+1,i) = 0.;
     elementosK(i,nel+1) = 0.;
   endfor
   elementosK(nel+1,nel+1) = 1.;
   FkGlobal(nel+1) = funcaoExata(b);
 
   Lambda = elementosK\FkGlobal;
      
   %Problema Local
   for n = 1:nel
     Ae = zeros(nen,nen);
     Fe = zeros(nen,1);
     for l = 1:nint
       xx = 0.;
       for j = 1:nen
         xx = xx + shg(1,j,l)*xl(k*(n-1)+j);
       endfor
       for i = 1:nen
         Fe(i) = Fe(i) + funcao(xx)*shg(1,i,l)*w(l)*h/2;
         for j = 1:nen
           Ae(i,j) = Ae(i,j) + shg(2,j,l)*2/h*shg(2,i,l)*2/h*w(l)*h/2;
         endfor
       endfor
     endfor
     for i = 1:nen
        Fe(i) += alfa*(shge(2,i,2)*2/h*Lambda(n+1) - shge(2,i,1)*2/h*Lambda(n) ) + beta*(shge(1,i,2)*Lambda(n+1) - shge(1,i,1)*Lambda(n));
        for j = 1:nen
          Ae(i,j) += -(shge(2,j,2)*2/h*shge(1,i,2) - shge(2,j,1)*2/h*shge(1,i,1)) + alfa*(shge(2,i,2)*2/h*shge(1,j,2) - shge(2,i,1)*2/h*shge(1,j,1)) + beta*(shge(1,j,2)*shge(1,i,2) - shge(1,j,1)*shge(1,i,1));
        endfor
      endfor

      u = zeros(nen);
      u = Ae\Fe;
      for i = 1:nen
        U(n,i) = u(i);
      endfor
   endfor
   
   %função exata
   x = a;
   exata = zeros(np,1);
   for i = 1:np
     exata(i) = funcaoExata(x);
     x += h/k;
   endfor
   x = a:h/k:b;
    
   %cálculo do erro L2
   erul2 = 0;
   for n = 1:nel
     eru = 0;
     for l = 1:nint
        uh = 0;
        xx = 0;
        for i = 1:nen
          uh = uh + shg(1,i,l)*U(n,i);
          xx = xx + shg(1,i,l)*xl(k*(n-1)+i);
        endfor
        eru = eru + ((funcaoExata(xx) - uh)**2) * w(l) * h/2;
     endfor
     erul2 = erul2 + eru;
   endfor
   erul2 = sqrt(erul2);
   erro(cont) = erul2;
   hh(cont) = h;
    
   
   %salva a resolucao
   nome = sprintf("log/PesosEPontosIntegracao%dalfa%dgrau%d.txt", cont, alfa, grau);
   save(nome, 'alfa', 'beta', 'Lambda', 'nen', 'nel', 'h', 'xl', 'U', 'x', 'exata');
    
  endfor
  
  %salva os erros
  nome = sprintf("log/Erros%d.txt", grau);
  save(nome, 'erro', 'hh' );

endfor
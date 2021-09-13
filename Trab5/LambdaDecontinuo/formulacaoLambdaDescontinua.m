clc
clear all
close all

format long;
%dominio
a = 0.00;
b = 1.00;

grau = 1;
beta0 = 10;
alfa = input('Insira o valor de alfa: ');

erro = zeros(4,1);
hh = zeros(4,1);

for grau = 2:2
   for cont = 1:2
   nel = 4^cont;
   h = (b-a)/nel;
   k = grau;
      
   beta = k*k*beta0/h
   
   nen = k+1;
   np =  k*nel+1
   nint = 2;
      
   Lambda = zeros(np);
   lambdak = zeros(nen);
   U = zeros(nen,nel);
   u = zeros(nen);

   elementosK = zeros(np,np);
   FkGlobal = zeros(np,1);
      
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
     Ak = zeros(nen,nen);
     Bk = zeros(nen,2);
     BTk = zeros(2,nen);
     Ck = zeros(2,2);
     Fk = zeros(nen,1);
        
     #parte integral de A e F no elemento
     for l = 1:nint
       xx = 0.;
       for j = 1:nen
         xx = xx + shg(1,j,l)*xl(k*(n-1)+j);
       endfor
       for i = 1:nen
         Fk(i) = Fk(i) + funcao(xx)*shg(1,i,l)*w(l)*h/2;
         for j = 1:nen
           Ak(i,j) = Ak(i,j) + shg(2,j,l)*2/h*shg(2,i,l)*2/h*w(l)*h/2;
         endfor
       endfor
     endfor
        
     #Calcula B, A , BT, C pra cada elemento
     for i = 1:nen
       Bk(i,1) += alfa*shge(2,i,1)*2/h + beta*shge(1,i,1);
       Bk(i,2) += -alfa*shge(2,i,2)*2/h - beta*shge(1,i,2);
       for j = 1:nen
         Ak(i,j) += -(shge(2,j,2)*2/h*shge(1,i,2) - shge(2,j,1)*2/h*shge(1,i,1)) + alfa*(shge(2,i,2)*2/h*shge(1,j,2) - shge(2,i,1)*2/h*shge(1,j,1)) + beta*(shge(1,j,2)*shge(1,i,2) - shge(1,j,1)*shge(1,i,1));
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
       FkGlobal(k*(n-1)+i) += Fkk(i);
       for j = 1:2
         elementosK(k*(n-1)+i,k*(n-1)+j) += elementoK(i,j);
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
     elementosK(i,i) = round(elementosK(i,i));
   endfor
        
   %Condição de Dirichlet saida
   FkGlobal(np) = funcaoExata(b);
   for i = np-(k+1):np
     FkGlobal(i) = FkGlobal(i) - (FkGlobal(np)*elementosK(i,np));
     elementosK(np,i) = 0.;
     elementosK(i,np) = 0.;
     elementosK(i,i) = round(elementosK(i,i));
   endfor
   elementosK(np,np) = 1.;
   FkGlobal(np) = funcaoExata(b);
      
   elementosK
   #FkGlobal
   
   #tentativa de consertar as casas decimais muito pequenas que aparecem
   if grau > 1
     for i = 1:np
       sum = 0.;
       for j = 1:np
         sum += elementosK(i,j);
       endfor
       tolerancia = 0.000000000001;
       if sum < abs(tolerancia)
         sum
         sum = 'soma muito pequena, vai dar erro, ajustando a matriz'
         for j = 1:np
            elementosK(i,j) = round(elementosK(i,j));
         endfor
       endif
     endfor
   endif
 
   Lambda = elementosK\FkGlobal
      
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
        U(i,n) = u(i);
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
    
   
   %salva a resolucao
   nome = sprintf("log/PesosEPontosIntegracao%dalfa%dgrau%d.txt", cont, alfa, grau);
   save(nome, 'alfa', 'beta', 'Lambda', 'h', 'xl', 'U', 'x', 'exata');
    
  endfor 
endfor
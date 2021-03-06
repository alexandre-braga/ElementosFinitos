clc
clear all
close all

format long;
%dominio
a = 0.00;
b = 1.00;

delta1 = input("Defina delta1 como -1/2 ou 0: \n");
delta1
delta2 = input("Defina delta2 como 1/2 ou 0: \n");
delta2
beta0 = input("Defina beta00 como 10 ou 0: \n");
beta0

derro = zeros(4,1);
erro = zeros(4,1);   
hh = zeros(4,1);

lambdaConhecido = input("Digite 1 se deseja Lambda = p, 0 caso não \n");

for grau = 1:4
   for cont = 1:4
   nel = 4^cont;
   h = (b-a)/nel;
   k = grau;
   
   beta = k*k*beta0/h
   nen = k+1
   np =  k*nel+1;
   nint = k+1
      
   Lambda = zeros(nel+1,1);
   U = zeros(nel,nen);
   P = zeros(nel,nen);
   solAux = zeros(2*nen);
   u = zeros(nen);
   p = zeros(nen);

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
   
   if lambdaConhecido == 0   
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
           Fk(i) += delta2*funcao(xx)*shg(2,i,l)*2/h*w(l)*h/2;
           Fk(nen+i) += -funcao(xx)*shg(1,i,l)*w(l)*h/2;
           for j = 1:nen
             %PHI j PHI i
             Ak(i,j) += ( (shg(1,j,l)*shg(1,i,l)) + delta1*(shg(1,j,l)*shg(1,i,l)) + delta2*(shg(2,j,l)*2/h*shg(2,i,l)*2/h) )*w(l)*h/2;
             %PSI j PHI i
             Ak(i,nen+j) += ( -(shg(1,j,l)*shg(2,i,l)*2/h) + delta1*(shg(2,j,l)*2/h*shg(1,i,l)) )*w(l)*h/2;
             %PHI j PSI i
             Ak(nen+i,j) += ( -(shg(2,j,l)*2/h*shg(1,i,l)) + delta1*(shg(1,j,l)*shg(2,i,l)*2/h) )*w(l)*h/2;
             %PSI j PSI i
             Ak(nen+i,nen+j) += (delta1*(shg(2,j,l)*2/h*shg(2,i,l)*2/h) )*w(l)*h/2;
           endfor
         endfor
       endfor
       
       #Calcula B, A , BT, C pra cada elemento
       for i = 1:nen
         %-PHI i lambda 1
         Bk(i,1) += -shge(1,i,1);
         %PHI i lambda 2
         Bk(i,2) += shge(1,i,2);
         %beta PSI i lambda 1
         Bk(nen+i,1) += beta*shge(1,i,1);
         %-beta PSI i lambda 2
         Bk(nen+i,2) += -beta*shge(1,i,2);
         for j = 1:nen
          Ak(nen+i,nen+j) += beta*(shge(1,j,2)*shge(1,i,2) - shge(1,j,1)*shge(1,i,1));
         endfor
       endfor
       
       BTk = transpose(Bk);
           
       Ck(1,1) = -beta;
       Ck(2,2) = beta;
       
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
   endif   
   
   if lambdaConhecido == 1
     for n = 1:nel+1
       Lambda(n) = funcaoExata(xl(n));
     endfor
   endif
   Lambda;
   
   %Problema Local
   for n = 1:nel
     Ae = zeros(2*nen,2*nen);
     Fe = zeros(2*nen,1);
     for l = 1:nint
       xx = 0.;
       for j = 1:nen
         xx = xx + shg(1,j,l)*xl(k*(n-1)+j);
       endfor
       for i = 1:nen
         %V
         Fe(i) += delta2*funcao(xx)*shg(2,i,l)*2/h*w(l)*h/2;
         %Q
         Fe(nen+i) += - funcao(xx)*shg(1,i,l)*w(l)*h/2;
         for j = 1:nen
           %PHI j PHI i
           Ae(i,j) += ( (shg(1,j,l)*shg(1,i,l)) + delta1*(shg(1,j,l)*shg(1,i,l)) + delta2*(shg(2,j,l)*2/h*shg(2,i,l)*2/h) )*w(l)*h/2;
           %PSI j PHI i
           Ae(i,nen+j) += ( -(shg(1,j,l)*shg(2,i,l)*2/h) + delta1*(shg(2,j,l)*2/h*shg(1,i,l)) )*w(l)*h/2;
           %PHI j PSI i
           Ae(nen+i,j) += ( -(shg(2,j,l)*2/h*shg(1,i,l)) + delta1*(shg(1,j,l)*shg(2,i,l)*2/h) )*w(l)*h/2;
           %PSI j PSI i
           Ae(nen+i,nen+j) += (delta1*(shg(2,j,l)*2/h*shg(2,i,l)*2/h) )*w(l)*h/2;
         endfor
       endfor
     endfor
     
     for i = 1:nen
       %V
       Fe(i) += -( shge(1,i,2)*Lambda(n+1) - shge(1,i,1)*Lambda(n) );
       %Q
       Fe(nen+i) += beta*( shge(1,i,2)*Lambda(n+1) - shge(1,i,1)*Lambda(n) );
       for j = 1:nen
         Ae(nen+i,nen+j) += beta*(shge(1,j,2)*shge(1,i,2) - shge(1,j,1)*shge(1,i,1));
       endfor
     endfor

     solAux = zeros(2*nen);
     u = zeros(nen);
     p = zeros(nen);
    
     solAux = Ae\Fe;
     u = solAux(1:nen);
     p = solAux(nen+1:2*nen);
    
     for i = 1:nen
       U(n,i) = u(i);
       P(n,i) = p(i);
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
    
   %cálculo do erro L2 para p
   erul2 = 0;
   for n = 1:nel
     eru = 0;
     for l = 1:nint
        ph = 0;
        xx = 0;
        for i = 1:nen
          ph = ph + shg(1,i,l)*P(n,i);
          xx = xx + shg(1,i,l)*xl(k*(n-1)+i);
        endfor
        eru = eru + ((funcaoExata(xx) - ph)**2) * w(l) * h/2;
     endfor
     erul2 = erul2 + eru;
   endfor
   erul2 = sqrt(erul2);
   erro(cont) = erul2;
   hh(cont) = h;
 
   %cálculo da derivada do erro L2 para u   
   erdul2 = 0.;
   for n = 1:nel
     erdu = 0;
     for l = 1:nint
        duh = 0;
        xx = 0;
        for i = 1:nen
          duh = duh + shg(2,i,l)*U(n,i);
          xx = xx + shg(1,i,l)*xl(k*(n-1)+i);
        endfor
        erdu = erdu + ((dfuncaoExata(xx) - duh)**2) * w(l) * h/2;
     endfor
     erdul2 = erdul2 + eru;
   endfor
   erdul2 = sqrt(erdul2);
   derro(cont) = erdul2;
   
   %salva a resolucao
   if lambdaConhecido == 1
    nome = sprintf("log/PesosEPontosIntegracaoConhecido%dgrau%d.txt", cont, grau);
    save(nome, 'beta', 'Lambda', 'nen', 'nel', 'h', 'xl', 'U', 'P', 'x', 'exata');
   else
    nome = sprintf("log/PesosEPontosIntegracaoDesconhecido%dgrau%d.txt", cont, grau);
    save(nome, 'beta', 'Lambda', 'nen', 'nel', 'h', 'xl', 'U', 'P', 'x', 'exata');
   endif

   
  endfor
  
  if lambdaConhecido == 1
    break;
  endif
  %salva os erros
  nome = sprintf("log/Erros%d.txt", grau);
  save(nome, 'erro', 'derro', 'hh' );

endfor
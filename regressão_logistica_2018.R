#Regressao no R

rm(list = ls())
install.packages("ROCR")
install.packages("Epi")
library(nortest) # Testes de normalidade 
library(boot) 

#Ler o arquivo de dados

local = file.choose()
#local <- tclvalue(tkgetOpenFile(title="Abrir Banco de Dados"))
dados <- read.table(file = local, header=TRUE, dec=".")

attach(dados)

names(dados)

# Primeiro realizando a seleção de variáveis já que sendo a regressão 
# logistica, usa-se o modelo de regressão generaizado com distribuição
# binomial e função de ligação "logit", os teste t sendo feito ao nível 
# de significância de 10%.

#Logistic Regression
library(xtable)
modelo=glm(PA~as.factor(SEXO)+as.factor(EST_CIVIL)+PESO+IDADE+as.factor(SED),binomial(link="logit"),dados)
xtable(summary(modelo))

# Analisando o summary do primeiro modelo gerado com todas as variáveis
# explicativas, a variável Estado Civil quando = 2 não passou no teste de
# significância do modelo que teve p-valor 0.9864 no teste t, portanto 
# ela será retirada do modelo.

#Exclusao de categoria numa variavel categorica
e2 = EST_CIVIL
e2[which(e2[]==2)]=1

modelo=glm(PA~as.factor(SEXO)+as.factor(e2)+PESO+IDADE+as.factor(SED),binomial(link="logit"),dados)
xtable(summary(modelo))

# Analisando o summary do modelo após a retirada de variável Estado 
# Civil = 2, a variável Estado Civil quando = 3 não passou no teste de 
# significância do modelo que teve p-valor 0.1747 no teste t, portanto
# ela será retirada do modelo.

e3 = e2
e3[which(e3[]==3)]=1

modelo=glm(PA~as.factor(SEXO)+as.factor(e3)+PESO+IDADE+as.factor(SED),binomial(link="logit"),dados)
xtable(summary(modelo))

# Então esse ficou o modelo final, com todas as variáveis passando no
# teste de significância ao nível de 10\% de significância.

b=modelo

#Overall Goodness of fit
s = summary(b); 
desvio=modelo$deviance
q.quadr=qchisq(0.90,modelo$df.residual)

desvio<q.quadr
# Agora verificando se o modelo é adequado, e sim o modelo dresultou em 
# ser adequado sim.

# Agora fazendo a analise de reíduos e diagnóstico.

#Valor ajustado e desvio residual
fit = fitted(b)
devres = glm.diag(b)$rd

#Grafico de Normalidade
library(nortest)
qqnorm(devres); qqline(devres, col=2)

# A partir do QQ Plot dos resíduos padronizados podemos observar que os 
# pontos estão um pouco distorcidos da reta de normalidade, podendo 
# assim suspeitar de uma não normalidade estar presente nos resíduos
# padronizados, agora vamos fazer o teste de Lilliefors e de Shapiro
# Wilks para ter uma conclusão mais precisa.


lillie.test(devres)
shapiro.test(devres)

# E em ambos os testes de normalidade H0 foi rejeitada, foi rejeitada a 
# hipótese de normalidade nos desvios padronizados com p-valores de 
# 2.456e-07 e 5.17e-05 no teste de Lilliefors e do Shapiro-WIlk 
# repspectivamente, podendo afirmar assim que os resíduos padronizados
# não seguem a normalidade.

#Verificar a funÏ„Ï€o de variÎ“ncia
plot(fit,devres, main = "Função de variância") 

# NÃO SEI O QUE COMENTAR SOBRE A FUNÇÃO DE VARIÂNCIA.

#Verificar a funÏ„Ï€o de LigaÏ„Ï€o
plot(fit,PA,main = "Função de ligação")

# NÃO SEI O QUE COMENTAR SOBRE A FUNÇÃO DE VARIÂNCIA.

#Indep. Erros
acf(devres)

# Analisando o ACF dos desvios padronizados podemos ver que o sétimo lag 
# está fora do intervalo de confiança com relação a autocorrelação dos 
# desvioa padronizados, porém como mesmo passando do limite superior do 
# intervalo de confiança continua a ser uma correlação baixa, próximo de
# 0.3, talvez não sendo muito preocupante, , mas fica a cargo do pesquisador
# decidir se considera como correlacionados ou não enquanto os demais lag's
# estão contidos no intervalo de confiança abaixo de $ \vert 0.2 \vert $.
# Ṕodendo interpretar que os desvios padronizados não são correlacionados.

#Odds Ratio
xtable(as.table(exp(b$coefficients[-1]))) # Cautela ao rodar este comando

# Essa é a razão de chances...

fit=fitted(b) # probabilidades estimadas para cada individuo da amostra

#Curva ROC
#? necess?rio instalar a biblioteca ROCR

library(ROCR)

#Considere em seu modelo o sucesso como Y=1 e o fracasso como Y=0.
pred <- prediction(fitted(b), PA)
perf <- performance(pred,"tpr","fpr") #Escolha do ponto de corte, TP e FP
area <- performance(pred,"auc") #Calcula a ?rea sob a curva ROC
plot(perf, main = " Cruva ROC") #Constroi o gr?fico da curva ROC

# Olhanco para a curva ROC podemos observar a qualidade do ajuste para o modelo,
# pois é obtido com base nas taxas de erro e acerto do modelo, possibilitando
# pegar o ponto de corte que maximiza o True Positive e minimize o False 
# Positive, podendo plotar uma reta que vai do canto superior esquerdo e acabe 
# no canto inferior direito e ao epgar o ponto em que a reta cruza com a curva é
# uma boa opção de???? HELP ME PLEASE. 
# PENSAR UMA FORMA DE IDENTIFICAR COMO PEGAR ESSE PONTO.

#Outra Opcao da ROC

library(Epi)
ROC(form=PA~as.factor(SEXO)+as.factor(e3)+PESO+IDADE+as.factor(SED),plot="ROC",MX=FALSE)

# Montando a matriz de contingencia
library(SDMTools)
confusion.matrix(PA, fit, threshold = 0.5)

# NÃO FUNCIONOU ESSE PACOTE NO MEU PC,ENTÃO NEM SEI A SAÍDA QUANTO MAIS O QUE 
# COMENTAR DELA.

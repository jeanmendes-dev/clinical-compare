# Carregar pacotes
if (!require("openxlsx")) install.packages("openxlsx")
if (!require("tidyverse")) install.packages("tidyverse")

library(openxlsx)
library(tidyverse)

# Definir semente para reprodutibilidade
set.seed(123)

# Gerar dados simulados
n <- 200  # número total de pacientes

dados_exemplo <- tibble(
  id = 1:n,
  grupo = rep(c("Controle", "Tratamento"), each = n/2),
  idade = round(c(
    rnorm(n/2, mean = 62, sd = 8),   # Controle
    rnorm(n/2, mean = 60, sd = 9)    # Tratamento
  )),
  sexo = c(
    sample(c("Masculino", "Feminino"), n/2, prob = c(0.55, 0.45), replace = TRUE),
    sample(c("Masculino", "Feminino"), n/2, prob = c(0.48, 0.52), replace = TRUE)
  ),
  imc = round(c(
    rnorm(n/2, mean = 28.5, sd = 4.2),
    rnorm(n/2, mean = 27.0, sd = 3.8)
  ), 1),
  diabetes = c(
    rbinom(n/2, 1, 0.35),
    rbinom(n/2, 1, 0.25)
  ),
  creatinina = round(c(
    rnorm(n/2, mean = 1.1, sd = 0.3),
    rnorm(n/2, mean = 0.95, sd = 0.25)
  ), 2),
  evento = c(
    rbinom(n/2, 1, 0.22),  # 22% de eventos no controle
    rbinom(n/2, 1, 0.12)   # 12% no tratamento
  )
) %>%
  mutate(
    diabetes = factor(diabetes, levels = c(0,1), labels = c("Não", "Sim")),
    evento = factor(evento, levels = c(0,1), labels = c("Não", "Sim"))
  ) %>%
  select(-id)

# Salvar como Excel
openxlsx::write.xlsx(dados_exemplo, file = "dados_exemplo.xlsx", rowNames = FALSE)

cat("✅ Arquivo 'dados_exemplo.xlsx' criado com sucesso na pasta de trabalho!\n")

#################################################################################

# === CARREGAR PACOTES ===
library(tidyverse)
library(gtsummary)
library(broom)
library(ggpubr)      # para arranjos de gráficos
library(openxlsx)

# === LER DADOS ===
dados <- read.xlsx("dados_exemplo.xlsx")

# === TABELA 1 (CORRIGIDA) ===
tabela1 <- dados %>%
  tbl_summary(
    by = grupo,
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    missing = "no"
  ) %>%
  add_p(
    test = list(
      all_continuous() ~ "t.test",
      all_categorical() ~ "chisq.test"
    )
  ) %>%
  modify_caption("Tabela 1: Características basais por grupo de tratamento") %>%
  as_gt()

print(tabela1)

# === GRÁFICOS PROFISSIONAIS ===

# 1. Boxplot: Idade por grupo
p1 <- ggplot(dados, aes(x = grupo, y = idade, fill = grupo)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("#2C7BB6", "#D7191C")) +
  labs(title = "Idade por Grupo", y = "Idade (anos)", x = "") +
  theme_minimal() +
  theme(legend.position = "none")

# 2. Boxplot: IMC por grupo
p2 <- ggplot(dados, aes(x = grupo, y = imc, fill = grupo)) +
  geom_boxplot(alpha = 0.7) +
  scale_fill_manual(values = c("#2C7BB6", "#D7191C")) +
  labs(title = "IMC por Grupo", y = "IMC (kg/m²)", x = "") +
  theme_minimal() +
  theme(legend.position = "none")

# 3. Gráfico de Barras: Proporção de Eventos
# === Correção da variável desfecho ===
dados <- dados %>%
  mutate(evento_bin = ifelse(evento == "Sim", 1, 0))

evento_prop <- dados %>%
  count(grupo, evento) %>%
  group_by(grupo) %>%
  mutate(pct = n / sum(n) * 100)

p3 <- ggplot(evento_prop, aes(x = grupo, y = pct, fill = evento)) +
  geom_col(position = "dodge") +
  scale_fill_manual(values = c("Não" = "#444444", "Sim" = "#E31A1C")) +  # ← Rótulos em português!
  labs(title = "Proporção de Eventos por Grupo", y = "Percentual (%)", x = "") +
  theme_minimal()

# 4. Densidade: Creatinina por grupo
p4 <- ggplot(dados, aes(x = creatinina, fill = grupo)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("#2C7BB6", "#D7191C")) +
  labs(title = "Distribuição de Creatinina", x = "Creatinina (mg/dL)", y = "Densidade") +
  theme_minimal()

# Organizar gráficos em uma única figura
figura <- ggarrange(p1, p2, p3, p4, ncol = 2, nrow = 2)
print(figura)

# Salvar os gráficos
ggsave("comparacao_grupos.png", figura, width = 12, height = 10, dpi = 300)


# === ANÁLISE ESTATÍSTICA AVANÇADA: Regressão Logística Ajustada ===
# Converter evento para 0/1
dados$evento_bin <- ifelse(dados$evento == "Sim", 1, 0)

modelo <- glm(evento_bin ~ grupo + idade + sexo + imc + diabetes, 
              data = dados, 
              family = binomial(link = "logit"))

# Resultados ajustados
resultado_ajustado <- modelo %>%
  tidy(exponentiate = TRUE, conf.int = TRUE) %>%
  mutate(across(c(estimate, conf.low, conf.high), ~ round(.x, 2))) %>%
  select(term, estimate, conf.low, conf.high, p.value)

print(resultado_ajustado)

# Destacar efeito do tratamento ajustado
or_trat <- resultado_ajustado %>%
  filter(term == "grupoTratamento") %>%
  pull(estimate)

cat("\n➡️ OR ajustado para 'Tratamento' (vs Controle):", or_trat, "\n")

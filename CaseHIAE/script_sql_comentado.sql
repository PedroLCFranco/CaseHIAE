-- Realizei as perguntas da tabela PNAD_COVID_092020 que apresenta todos os dados do PNAD_COVID de Setembro.
-- Validei dados de forma geral aplicando os criterios das perguntas selecionadas.

select count(1) from PEDRO_DEV.dbo.PNAD_COVID_092020 where B005 = 1; -- 199 Pessoas foram internadas no mês de SET/2020

select count(1) from PEDRO_DEV.dbo.PNAD_COVID_092020 where B009B = 1; -- 3905 Com SWA3 COVID Positivo

select * from PEDRO_DEV.dbo.PNAD_COVID_092020 where B005 = 1 and B009B = 1; -- 52 Foram internados com SWA3 COVID Positivo


-- Aqui seleciono na tabela apenas as colunas que preciso, utilizando a clausula where para filtrar o resultado em função a minha pesquisa

select UF, Ano, V1013, A002, A003, B005, B006, B009A, B009B, B0101, B0102, B0103 -- Colunas
	into PEDRO_DEV.dbo.tb_analise -- nome da tabela nova
from PEDRO_DEV.dbo.PNAD_COVID_092020 -- Tabela PNAD_COVID
	where B005 = 1 and B009B = 1 and A002 >= 18 -- Filtros B005 verifica se a pessoa está internada, B009B Vê Se o caso e positivo para SWA3 COVID, A002 verifica se a pessoa e tem 18 anos ou mais

select * from PEDRO_DEV.dbo.tb_analise --Verifico se as informações estão certas na tabela

-- Iniciando modelagem da tabela nova.

-- Para renomear as colunas e para que os dados escolhidos fiquem faceis de entender, usamos o comando 'sp_rename'
 -- Após o comando sp_rename fica: 'nome_tabela.coluna', 'novo_nome_tabela', 'COLUMN';
EXEC sp_rename 'dbo.tb_analise.UF', 'id_uf', 'COLUMN';
EXEC sp_rename 'dbo.tb_analise.V1013', 'mes', 'COLUMN';
EXEC sp_rename 'dbo.tb_analise.A002', 'idade', 'COLUMN';
EXEC sp_rename 'dbo.tb_analise.B005', 'internado', 'COLUMN';
EXEC sp_rename 'dbo.tb_analise.A003', 'genero', 'COLUMN';


--Mapeio os generos masculino M e Feminino F
update PEDRO_DEV.dbo.tb_analise set genero = 'M' where genero = '1';
update PEDRO_DEV.dbo.tb_analise set genero = 'F' where genero = '2';

--Adiciono um campo de referencia na tabela para mapear o mes de origem
alter table tb_analise add ref varchar(50);
update tb_analise set ref = 'F9';


-- Faço as alterações a cima para as tabelas com os 3 meses de referencia que escolhi Set, Out e Nov

--Crio tabela para mapear as UF com código e seus municipios.
Create table dbo.uf
(pk_uf varchar(50) primary key not null, --Nome da coluna e seu tipo, não podendo ser nula
ds_uf text not null,
uf varchar(3) not null);

-- Inserindo dados na tela de UF

INSERT INTO UF (pk_uf, ds_uf, uf) -- Nome da tabela e entre parenteces as colunas onde os dados vão ser inseridos
VALUES (11, 'Município de Porto Velho', 'RO'), -- Valores que vou atualizar
(12, 'Município de Rio Branco', 'AC'),
(13, 'Município de Manaus', 'AM'),
(14, 'Município de Boa Vista', 'RR'),
(15, 'Município de Belém', 'PA'),
(16, 'Município de Macapá', 'AP'),
(17, 'Município de Palmas', ' TO'),
(21, 'Município de São Luís', 'MA'),
(22, 'Município de Teresina', 'PI'),
(23, 'Município de Fortaleza', 'CE'),
(24, 'Município de Natal', 'RN'),
(25, 'Município de João Pessoa', 'PB'),
(26, 'Município de Recife', 'PE'),
(27, 'Município de Maceió', 'AL'),
(28, 'Município de Aracaju', 'SE'),
(29, 'Município de Salvador', 'BA'),
(31, 'Município de Belo Horizonte', 'MG'),
(32, 'Município de Vitória', 'ES'),
(33, 'Município de Rio de Janeiro', 'RJ'),
(35, 'Município de São Paulo', 'SP'),
(41, 'Município de Curitiba', 'PR'),
(42, 'Município de Florianópolis', 'SC'),
(43, 'Município de Porto Alegre', 'RS'),
(50, 'Município de Campo Grande', 'MS'),
(51, 'Município de Cuiabá', 'MT'),
(52, 'Município de Goiânia', 'GO'),
(53, 'Município de Brasília', 'DF');


-- Criando tabela genero
--DROP table genero
Create table genero (
pk_genero varchar(50) primary key,
ds_genero varchar (50) not null
);

-- Inserindo os dados
Insert into genero (pk_genero, ds_genero)
values ('F', 'Feminino'),
	   ('M', 'Masculino');


-- Criando tabela formulario
--drop table formulario
Create table formulario (
pk_registro varchar (50) primary key,
tp_pesquisa varchar (50) not null,
dt_pesquisa varchar (10) not null
);


-- Inserindo valores tabela formulario

Insert into formulario (pk_registro, tp_pesquisa, dt_pesquisa)
values ('F9', 'PNAD_COVID', '09/2020'),
	   ('F10', 'PNAD_COVID', '10/2020'),
	   ('F11', 'PNAD_COVID', '11/2020');

-- Criando coluna de chave estrangeira entre minha tabela de analise e a tabela de formulario.

ALTER TABLE tb_analise
ADD CONSTRAINT fk_ref
FOREIGN KEY (ref)
REFERENCES formulario (pk_registro);

-- Criando coluna de chave estrangeira entre minha tabela de analise e a tabela de uf.
ALTER TABLE tb_analise
ADD CONSTRAINT fk_id_uf
FOREIGN KEY (id_uf)
REFERENCES uf (pk_uf);


-- Criando coluna de chave estrangeira entre minha tabela de analise e a tabela de genero.
ALTER TABLE tb_analise
ADD CONSTRAINT fk_genero
FOREIGN KEY (genero)
REFERENCES genero (pk_genero);


-- Insiro as tabelas que criei para os outros meses na tabela principal
INSERT INTO tb_analise
SELECT * FROM tb_analise_10;


INSERT INTO tb_analise
SELECT * FROM tb_analise_11;

-- Testo se as chaves estrangeiras estão funcionando corretamente
select id_uf, C.ds_uf, A.genero, A.idade, internado
from tb_analise A
join genero B on B.pk_genero = A.genero
join uf C on C.pk_uf = A.id_uf


select dt_pesquisa, tp_pesquisa, idade
from tb_analise A
join formulario B on B.pk_registro = A.ref


-- Importo a tabela para o power bi

select * from tb_analise where internado = 1 and B009B = 'Sim' and B0103 = 'Sim'-- and B0101 = 'Sim' and B0102 = 'Sim'
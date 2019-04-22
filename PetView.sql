﻿create database dbPetView
GO

use dbPetView
GO

-- TABELAS

create table tbEndereco(
cep char(8) not null,
numero int not null,
rua varchar(50) not null,
bairro varchar(50) not null,
complemento varchar(20),
cidade varchar(50) not null,
uf char(2) not null,
constraint PK_tbEndereco primary key clustered (cep, numero)
);
GO

create table tbFuncionario(
cod_funcionario int identity(1,1) constraint PK_tbFuncionario primary key,
nome_func varchar(70) not null,
cpf_func char(11) not null,
rg_func char(9) not null,
status_func char(8) not null constraint DF_tbFuncionario_status default 'Ativo', -- ativo ou demitido
tel_func char(10),
cel_func char(11),
email_func varchar(100),
cargo_func varchar(30) not null,
salario_func money not null,
cep_func char(8) not null,
numcasa_func int not null,
constraint FK_tbFuncionario_tbEndereco foreign key(cep_func, numcasa_func) references tbEndereco(cep,numero),
constraint CK_tbFuncionario_salario check(salario_func >= 0.00)
);
GO

create table tbUsuario (
cod_usuario int identity(1,1) constraint PK_tbUsuario primary key,
nome_usuario varchar(25) not null,
ativacao_usuario bit not null constraint DF_tbUsuario_ativo default 0,
data_cadastro datetime not null constraint DF_tbUsuario_data default getdate(),
nome_login varchar(25) not null,
senha_login varchar(20) not null,
cod_funcionario int not null,
constraint FK_tbUsuario_tbFuncionario foreign key(cod_funcionario) references tbFuncionario(cod_funcionario)
);
GO

create table tbDono(
cod_dono int identity(1,1) constraint PK_tbDono primary key,
nome_dono varchar(70) not null,
cpf_dono char(11) not null,
rg_dono char(9) not null,
cel_dono char(11) not null,
tel_dono char(10),
email_dono varchar(100) not null,
cep_dono char(8) not null,
numcasa_dono int not null,
constraint FK_tbDono_tbEndereco foreign key(cep_dono, numcasa_dono) references tbEndereco(cep,numero)
);
GO

create table tbAnimal(
cod_animal int identity(1,1) constraint PK_tbAnimal primary key,
rga int,
cod_dono int not null,
nome_animal varchar(30) not null,
idade int not null,
raca_animal varchar(30) not null,
especie varchar(30) not null,
descricao varchar(100) not null,
constraint FK_tbAnimal_tbDono foreign key(cod_dono) references tbDono(cod_dono)
);
GO

create table tbMedico(
cod_medico int identity(1,1) constraint PK_tbMedico primary key,
crmv int not null,
nome_med char(70) not null,
funcao_med varchar(30) not null,
cpf_med char(11) not null,
rg_med char(9) not null,
cel_med char(10) not null,
tel_med char(10),
email_med varchar(100) not null,
salario_med money not null,
cep_med char(8) not null,
numcasa_med int not null,
constraint FK_tbMedico_tbEndereco foreign key(cep_med, numcasa_med) references tbEndereco(cep,numero),
constraint CK_tbMedico_salario check(salario_med >= 0.00)
);
GO

create table tbConsulta(
cod_consulta int identity(1,1) constraint PK_tbConsulta primary key,
cod_animal int not null,
cod_medico int not null,
sintomas varchar(300) not null,
diagnostico varchar(300) not null,
custo_consulta money not null,
tipo_consulta varchar(15) not null,
constraint FK_tbConsulta_tbAnimal foreign key(cod_animal) references tbAnimal(cod_animal),
constraint FK_tbConsulta_tbMedico foreign key(cod_medico) references tbMedico(cod_medico)
);
GO

create table tbTratamento(
cod_tratamento int identity(1,1) constraint PK_tbTratamento primary key,
cod_animal int not null,
cod_medico int not null,
cod_consulta int not null,
tipo_tratamento varchar(30) not null,
observacao_tratamento varchar(150) not null,
custo_tratamento money not null,
constraint FK_tbTratamento_tbAnimal foreign key(cod_animal) references tbAnimal(cod_animal),
constraint FK_tbTratamento_tbMedico foreign key(cod_medico) references tbMedico(cod_medico),
constraint FK_tbTratamento_tbConsulta foreign key(cod_consulta) references tbConsulta(cod_consulta)
);
GO

create table tbExame(
cod_exame int identity(1,1) constraint PK_tbTratamento primary key,
cod_animal int not null,
cod_medico int not null,
cod_consulta int not null,
tipo_exame varchar(30) not null,
observacao_exame varchar(150) not null,
custo_exame money not null,
constraint FK_tbExame_tbAnimal foreign key(cod_animal) references tbAnimal(cod_animal),
constraint FK_tbExame_tbMedico foreign key(cod_medico) references tbMedico(cod_medico),
constraint FK_tbExame_tbConsulta foreign key(cod_consulta) references tbConsulta(cod_consulta)
);
GO

-- PROCEDURES

create proc sp_insert_medico(
@cep char(8),
@numero int,
@rua varchar(50),
@bairro varchar(50),
@complemento varchar(20),
@cidade varchar(50),	
@uf char(2),
@numcasa int, 
@crmv int,
@nome_med char(70),
@funcao_med varchar(30),
@cpf_med char(11),
@rg_med char(9),
@cel_med char(10),
@tel_med char(10),
@email_med varchar(100),
@salario_med money
) 
as 
	begin
		if(@tel_med = '') set @tel_med = null;
		if(@complemento = '')set @complemento = 'Sem complemento';

		insert into tbEndereco (cep, numero, rua, bairro, complemento, cidade, uf)
				values (@cep, @numero, @rua, @bairro, @complemento, @cidade, @uf);
		insert into tbMedico(crmv, nome_med, funcao_med, cpf_med, rg_med, cel_med, tel_med, salario_med, cep_med, numcasa_med)
						 values(@crmv, @nome_med, @funcao_med, @cpf_med, @rg_med, @cel_med, @tel_med, @salario_med, @cep, @numcasa);
	end
 GO

create proc sp_delete_medico(
@cod_medico int
)as
begin
    delete from tbMedico where cod_medico = @cod_medico;
end
GO

create proc sp_update_medico(
@cod_medico int,
@crmv int,
@nome_med char(70),
@funcao_med varchar(30),
@cpf_med char(11),
@rg_med char(9),
@cel_med char(10),
@tel_med char(10),
@salario_med money
)as
begin
	update tbMedico
	set crmv = @crmv, nome_med = @nome_med, funcao_med = @funcao_med, cpf_med = @cpf_med, rg_med = @rg_med, cel_med = @cel_med, tel_med = @tel_med,
	salario_med = @salario_med
	where cod_medico = @cod_medico;
end
GO
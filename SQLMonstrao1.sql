USE `heric_corporation`;
DROP PROCEDURE IF EXISTS `heric_corporation`.`novoAluguel_16`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `novoAluguel_16`(
    lista VARCHAR(255), 
    vHospedagem VARCHAR(10), 
    vDataInicio DATE, 
    vDias INTEGER, 
    vPrecoUnitario DECIMAL(10,2)
)
BEGIN
    DECLARE vClienteNome VARCHAR(150);
    DECLARE fimCursor INTEGER DEFAULT 0;
    DECLARE vnome VARCHAR(255);
    DECLARE cursor1 CURSOR FOR SELECT nome FROM temp_nomes;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET fimCursor = 1;
    DROP TEMPORARY TABLE IF EXISTS temp_nomes;
    CREATE TEMPORARY TABLE temp_nomes (nome VARCHAR(255));
    CALL inclui_lista(lista);
    OPEN cursor1;
    FETCH cursor1 INTO vnome;
    WHILE fimCursor = 0 DO
        IF vnome IS NOT NULL THEN
            SET vClienteNome = vnome;
            CALL novoAluguel_15(vClienteNome, vHospedagem, vDataInicio, vDias, vPrecoUnitario);
        END IF;
        FETCH cursor1 INTO vnome;
    END WHILE;
    CLOSE cursor1;
    DROP TEMPORARY TABLE IF EXISTS temp_nomes;
END$$
DELIMITER ;

CALL novoAluguel_16('Lívia Fogaça', '8635', '2023-05-29', 5, 45);

SELECT AVG(nota) media, tipo
FROM avaliacoes a
JOIN hospedagens h
ON h.hospedagem_id = a.hospedagem_id
GROUP BY tipo;

SELECT
  TRIM(nome) Nome,
  CONCAT(SUBSTRING(cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS CPF_Mascarado
FROM
  clientes;
  
SELECT tipo, SUM(DATEDIFF(data_fim, data_inicio)) AS TotalDias
FROM alugueis a
JOIN hospedagens h
ON a.hospedagem_id = h.hospedagem_id
GROUP BY tipo;

SELECT hospedagem_id, nota,
CASE nota
        WHEN 5 THEN 'Excelente'
        WHEN 4 THEN 'Ótimo'
        WHEN 3 THEN 'Muito Bom'
        WHEN 2 THEN 'Bom'
        ELSE 'Ruim'
END AS StatusNota
FROM avaliacoes;

SELECT 
    CASE nota
        WHEN 5 THEN 'Excelente'
        WHEN 4 THEN 'Ótimo'
        WHEN 3 THEN 'Muito Bom'
        WHEN 2 THEN 'Bom'
        ELSE 'Ruim'
    END AS StatusNota,
    COUNT(*) AS Quantidade
FROM avaliacoes
GROUP BY StatusNota
ORDER BY Quantidade DESC;

DELIMITER $$
CREATE FUNCTION FormatandoCPF (ClienteID INT)
RETURNS VARCHAR(50) DETERMINISTIC
BEGIN
DECLARE NovoCPF VARCHAR(50);
SET NovoCPF = (
    CONCAT(SUBSTRING (cpf, 1, 3), '.', SUBSTRING(cpf, 4, 3), '.', SUBSTRING(cpf, 7, 3), '-', SUBSTRING(cpf, 10, 2)) AS CPF_Mascarado
FROM clientes
WHERE cliente_id = ClienteID );

RETURN NovoCPF;
END$$
DELIMITER ;

SELECT TRIM(nome) Nome, FormatandoCPF (1) AS CPF FROM clientes WHERE cliente_id = 1;

SELECT * FROM alugueis;

DELIMITER $$
CREATE FUNCTION InfoAluguel(IdAluguel INT)
RETURNS VARCHAR(255) DETERMINISTIC
BEGIN

DECLARE NomeCliente VARCHAR(100);
DECLARE PrecoTotal DECIMAL(10,2);
DECLARE Dias INT;
DECLARE ValorDiaria DECIMAL(10,2);
DECLARE Resultado VARCHAR(255);

SELECT * c.nome, a.preco_total, DATEDIFF(data_fim, data_inicio)
INTO NomeCliente, PrecoTotal, Dias
FROM alugueis a
JOIN clientes c
ON a.cliente_id = c.cliente_id
WHERE a.aluguel_id = IdAluguel

SET ValorDiaria = PrecoTotal / Dias;

SET Resultado = CONCAT('Nome: ', NomeCliente, ', Valor Diário: R$', FORMAT(ValorDiaria,2));

RETURN Resultado;

END$$

DELIMITER ;

DELIMITER $$
CREATE FUNCTION CalcularDescontoPorDias(AluguelID INT)
RETURNS INT DETERMINISTIC

BEGIN
DECLARE Desconto INT;
SELECT
        CASE
                WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 4 AND 6 THEN 5
                WHEN DATEDIFF(data_fim, data_inicio) BETWEEN 7 AND 9 THEN 10
                WHEN DATEDIFF(data_fim, data_inicio) >= 10 THEN 15
                ELSE 0
        END
        INTO Desconto
FROM alugueis
WHERE aluguel_id = AluguelID;
RETURN Desconto;
END$$

DELIMITER ;
-- -----------------------------------------------------------------------------------------------------------------------
-- BD 2021/22 - etapa E2 - bd043 – 
-- 56707, Carolina Silva, TP17, participação: 33,(3)%
-- 54859, Rita Rodrigues, TP18, participação: 33,(3)%
-- 56692, Susana Caramujo, TP17, participação: 33,(3)%
-- -----------------------------------------------------------------------------------------------------------------------

/*
1. Nome e país de todos os jogadores que já marcaram pelo menos dois golos em
algum jogo com a França (FR). O ano desses jogos também deverá ser
apresentado; e os resultados ordenados de forma descendente por ano, e
ascendente por país e nome. Nota: pretende-se uma interrogação sem subinterrogações: apenas com um SELECT.
*/

SELECT jr.nome, jr.pais, jg.ano
FROM jogador jr, jogo jg, participa pa
WHERE pa.jogador = jr.numero
AND pa.jogo_ano = jg.ano
AND pa.jogo_sigla = jg.sigla
AND pa.jogo_numero = jg.numero
AND pa.golos >= 2
AND (jg.equipa1 = "FR" OR jg.equipa2 = "FR")
ORDER BY jg.ano DESC, jr.pais ASC, jr.nome ASC;

/*
2. Número, nome, posição e país dos jogadores que são Top em pelo menos uma
das posições: ponta de lança e avançado, ou que tenham ‘Ron’ no nome e
tenham começado a jogar antes (*) do último Mundial no Brasil (2014). Nota:
pode usar construtores de conjuntos.
*/

(SELECT jr1.numero, jr1.nome, po1.nome, jr1.pais
FROM jogador jr1, posicao po1, e_bom e1
WHERE jr1.numero = e1.jogador
AND e1.posicao = po1.codigo
AND e1.tipo = "top"
AND e1.posicao = po1.codigo
AND (po1.nome = "ponta_lanca" OR po1.nome = "avancado"))
UNION
(SELECT jr2.numero, jr2.nome, po2.nome, jr2.pais
FROM jogador jr2, posicao po2, e_bom e2
WHERE jr2.numero = e2.jogador
AND e2.posicao = po2.codigo
AND jr2.nome LIKE '%Ron%'
AND jr2.ano < 2014);

/*
3. Identificação dos jogos de quartos de final realizados desde o Mundial
Alemanha’2006 em que participou, pelo menos, um jogador que iniciou
atividade nesse ano e tem na camisola um nome com 7 letras, terminado por ‘o’ .
*/

SELECT pa.jogo_ano, pa.jogo_sigla, pa.jogo_numero
FROM participa pa
WHERE pa.jogo_sigla = "QF"
AND pa.jogo_ano >= 2006
AND EXISTS (SELECT *
			FROM jogador jr
            WHERE pa.jogador = jr.numero
            AND jr.ano = 2006
            AND jr.camisola LIKE "______o");
            
/*
4. Nome, ano e país dos jogadores que nasceram antes do Mundial USA’1994 , e
que nunca participaram à defesa, em oitavos de final com o Reino Unido (UK).
*/

SELECT DISTINCT jr.nome, jr.nascimento, jr.pais
FROM jogador jr, participa pa, jogo jg, posicao po
WHERE jr.nascimento < 1994
AND pa.jogador = jr.numero
AND pa.posicao <> po.codigo
AND po.nome = "defesa"
AND pa.jogo_sigla = "OF"
AND pa.jogo_ano = jg.ano
AND pa.jogo_sigla = jg.sigla
AND pa.jogo_numero = jg.numero
AND (jg.equipa1 = "UK" OR jg.equipa2 = "UK");

/*
5. Identificação dos jogos em fases de grupo em que tenham participado jogadores
italianos Top em todas as posições. Nota: o resultado deve vir ordenado pelo ano
de forma descendente e pela sigla e número do jogo, de forma ascendente.
*/

SELECT DISTINCT jg.ano, jg.sigla, jg.numero
FROM jogo jg
WHERE (NOT EXISTS (SELECT po.codigo
					FROM posicao po
                    WHERE (NOT EXISTS (SELECT pa.jogador
										FROM participa pa, jogador jr, e_bom e
                                        WHERE pa.posicao = po.codigo
                                        AND pa.jogo_ano = jg.ano
                                        AND pa.jogo_sigla = jg.sigla
                                        AND pa.jogo_numero = jg.numero
                                        AND pa.jogador = jr.numero
                                        AND jr.pais = "IT"
                                        AND e.jogador = pa.jogador
                                        AND e.tipo = "top"))))
AND jg.sigla IN ("A", "B", "C", "D", "E", "F", "G", "H")
ORDER BY jg.ano DESC, jg.sigla ASC, jg.numero ASC;

/*
6. Número de jogos em que participou cada jogador, em cada posição. Nota: os
resultados devem ser ordenados pelo nome e número do jogador e pela posição,
de forma ascendente.
*/

SELECT jr.nome, jr.numero, pa.posicao, COUNT(*) AS "Número jogos"
FROM jogador jr, participa pa
WHERE pa.jogador = jr.numero
GROUP BY jr.nome, jr.numero, pa.posicao
ORDER BY jr.nome ASC, jr.numero ASC, pa.posicao ASC;

/*
7. Nome, número e nacionalidade dos jogadores que participaram em mais
semifinais, em cada posição. Notas: em caso de empate, devem ser mostrados
todos os jogadores em causa.
*/

SELECT jr.nome, jr.numero, jr.pais, pa.posicao
FROM jogador jr, participa pa
WHERE pa.jogador = jr.numero
AND pa.jogo_sigla = "SF"
GROUP BY pa.posicao, jr.numero
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
						FROM jogador jr2, participa pa2
                        WHERE pa2.jogador = jr2.numero
                        AND pa2.jogo_sigla = "SF"
                        AND pa2.posicao = pa.posicao
                        GROUP BY pa2.jogador, jr2.numero);
                        
/*
8. Para cada ano de início de actividade, o número e nome na camisola do jogador
que participou em mais jogos. Apresentar também o número total de jogos em
que jogou, e o maior e menor número de golos que marcou nesses jogos. Nota:
em caso de empate do total de jogos, mostrar todos os jogadores em causa.
*/

SELECT jr.ano, pa.jogador, jr.camisola, COUNT(*) AS total_jogos, MAX(pa.golos + pa.autogolos) AS "Max golos", MIN(pa.golos + pa.autogolos) AS "Min golos"
FROM participa pa, jogador jr
WHERE pa.jogador = jr.numero
GROUP BY jr.ano, jr.numero
HAVING total_jogos >= ALL (SELECT COUNT(*)
							FROM participa pa2, jogador jr2
                            WHERE pa2.jogador = jr2.numero
                            AND jr2.ano = jr.ano
                            GROUP BY pa2.jogador);
                            
/*
9. Nome, ano de nascimento e nacionalidade dos jogadores que nasceram depois
do ano do Ronaldo (1985) e participaram em menos de 6 jogos em mundiais,
mesmo que não tenham participado em nenhum. Pretende-se uma interrogação
sem sub-interrogações: apenas com um SELECT.
*/

SELECT jr.nome, jr.nascimento, jr.pais
FROM jogador jr LEFT OUTER JOIN participa pa 
	ON jr.numero = pa.jogador
WHERE jr.nascimento > 1985
GROUP BY jr.numero, jr.nome, jr.nascimento, jr.pais
HAVING COUNT(*) < 6;
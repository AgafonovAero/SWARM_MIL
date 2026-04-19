function rezultat = raschet_passivnoi_kinematiki(scenarii)
if nargin < 1 || ~isstruct(scenarii)
    error('%s', 'Для расчета пассивной кинематики требуется структура сценария.');
end

proverit_scenarii(scenarii, 'структура сценария в памяти');
oblast_poleta = proverit_oblast_poleta( ...
    scenarii.oblast_poleta, ...
    'области полета в структуре сценария');
sostoyaniya_bvs = sozdat_sostoyanie_bvs_iz_scenariya(scenarii);

nachalnoe_chislo = double(scenarii.nachalnoe_chislo);
rng(nachalnoe_chislo, 'twister');

shag_modelirovaniya = double(scenarii.shag_modelirovaniya);
vremya_modelirovaniya = double(scenarii.vremya_modelirovaniya);
vremya = 0:shag_modelirovaniya:vremya_modelirovaniya;

chislo_bvs = numel(sostoyaniya_bvs);
chislo_momentov = numel(vremya);

polozheniya = zeros(chislo_momentov, chislo_bvs, 3);
skorosti = zeros(chislo_momentov, chislo_bvs, 3);
identifikatory_bvs = cell(1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
    identifikatory_bvs{nomer_bvs} = sostoyaniya_bvs(nomer_bvs).id_bvs;
    polozheniya(1, nomer_bvs, :) = sostoyaniya_bvs(nomer_bvs).polozhenie;
    skorosti(1, nomer_bvs, :) = sostoyaniya_bvs(nomer_bvs).skorost;
end

tekushchie_sostoyaniya = sostoyaniya_bvs;
for nomer_momenta = 2:chislo_momentov
    tekushchie_sostoyaniya = shag_kinematiki_roya( ...
        tekushchie_sostoyaniya, ...
        shag_modelirovaniya, ...
        oblast_poleta);

    for nomer_bvs = 1:chislo_bvs
        polozheniya(nomer_momenta, nomer_bvs, :) = ...
            tekushchie_sostoyaniya(nomer_bvs).polozhenie;
        skorosti(nomer_momenta, nomer_bvs, :) = ...
            tekushchie_sostoyaniya(nomer_bvs).skorost;
    end
end

rezultat = struct();
rezultat.id_scenariya = char(string(scenarii.id_scenariya));
rezultat.vremya = vremya;
rezultat.id_bvs = identifikatory_bvs;
rezultat.polozheniya = polozheniya;
rezultat.skorosti = skorosti;
rezultat.chislo_bvs = chislo_bvs;
rezultat.shag_modelirovaniya = shag_modelirovaniya;
rezultat.vremya_modelirovaniya = vremya_modelirovaniya;
rezultat.primechanie = [ ...
    'Пассивная кинематика с постоянной скоростью, ' ...
    'без управления, связи, обучения и изменения запаса энергии.' ...
    ];
end

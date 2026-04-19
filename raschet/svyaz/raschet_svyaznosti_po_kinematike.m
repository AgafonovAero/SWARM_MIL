function rezultat = raschet_svyaznosti_po_kinematike(rezultat_kinematiki, parametry_svyazi)

rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki);
parametry_svyazi = proverit_parametry_svyazi(parametry_svyazi);

chislo_momentov = numel(rezultat_kinematiki.vremya);
pervye_sostoyaniya_bvs = sostavit_sostoyaniya_iz_rezultata( ...
    rezultat_kinematiki, 1);
pervyi_graf = postroit_graf_svyaznosti( ...
    pervye_sostoyaniya_bvs, ...
    parametry_svyazi, ...
    rezultat_kinematiki.shag_modelirovaniya);
grafy_po_vremeni = repmat(pervyi_graf, 1, chislo_momentov);

for nomer_momenta = 2:chislo_momentov
    sostoyaniya_bvs = sostavit_sostoyaniya_iz_rezultata( ...
        rezultat_kinematiki, nomer_momenta);
    grafy_po_vremeni(nomer_momenta) = postroit_graf_svyaznosti( ...
        sostoyaniya_bvs, ...
        parametry_svyazi, ...
        rezultat_kinematiki.shag_modelirovaniya);
end

priznaki_svyaznosti = [grafy_po_vremeni.svyazen];
chislo_linii_po_vremeni = [grafy_po_vremeni.chislo_linii];
srednyaya_stepen_po_vremeni = [grafy_po_vremeni.srednyaya_stepen];

rezultat = struct();
rezultat.id_scenariya = rezultat_kinematiki.id_scenariya;
rezultat.vremya = rezultat_kinematiki.vremya;
rezultat.id_bvs = rezultat_kinematiki.id_bvs;
rezultat.grafy_po_vremeni = grafy_po_vremeni;
rezultat.dolya_vremeni_svyaznogo_roya = mean(double(priznaki_svyaznosti));
rezultat.srednee_chislo_linii = mean(chislo_linii_po_vremeni);
rezultat.srednyaya_stepen_po_vremeni = mean(srednyaya_stepen_po_vremeni);
rezultat.primechanie = [ ...
    'Расчет связности по пассивной кинематике без маршрутизации, ' ...
    'без изменения траекторий и без деления роя на звенья.' ...
    ];
end

function rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki)
if nargin < 1 || ~isstruct(rezultat_kinematiki)
    error('%s', 'Для расчета связности требуется структура результата кинематики.');
end

obyazatelnye_polya = {
    'id_scenariya'
    'vremya'
    'id_bvs'
    'polozheniya'
    'skorosti'
    'chislo_bvs'
    'shag_modelirovaniya'
    'vremya_modelirovaniya'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_kinematiki, imya_polya)
        error('%s', sprintf( ...
            'В результате кинематики отсутствует поле %s.', ...
            imya_polya));
    end
end

if ~isnumeric(rezultat_kinematiki.vremya) || isempty(rezultat_kinematiki.vremya)
    error('%s', 'Поле vremya результата кинематики должно быть непустым числовым массивом.');
end

if ~iscell(rezultat_kinematiki.id_bvs) || isempty(rezultat_kinematiki.id_bvs)
    error('%s', 'Поле id_bvs результата кинематики должно быть непустым списком идентификаторов.');
end

if ~isnumeric(rezultat_kinematiki.chislo_bvs) ...
        || ~isscalar(rezultat_kinematiki.chislo_bvs) ...
        || ~isfinite(rezultat_kinematiki.chislo_bvs) ...
        || rezultat_kinematiki.chislo_bvs <= 0
    error('%s', 'Поле chislo_bvs результата кинематики должно быть положительным числом.');
end

if ~isnumeric(rezultat_kinematiki.shag_modelirovaniya) ...
        || ~isscalar(rezultat_kinematiki.shag_modelirovaniya) ...
        || ~isfinite(rezultat_kinematiki.shag_modelirovaniya) ...
        || rezultat_kinematiki.shag_modelirovaniya <= 0
    error('%s', 'Поле shag_modelirovaniya результата кинематики должно быть положительным числом.');
end

if ~isnumeric(rezultat_kinematiki.vremya_modelirovaniya) ...
        || ~isscalar(rezultat_kinematiki.vremya_modelirovaniya) ...
        || ~isfinite(rezultat_kinematiki.vremya_modelirovaniya) ...
        || rezultat_kinematiki.vremya_modelirovaniya <= 0
    error('%s', 'Поле vremya_modelirovaniya результата кинематики должно быть положительным числом.');
end

if ~isnumeric(rezultat_kinematiki.polozheniya) ...
        || ndims(rezultat_kinematiki.polozheniya) ~= 3 ...
        || size(rezultat_kinematiki.polozheniya, 3) ~= 3
    error('%s', 'Поле polozheniya результата кинематики должно иметь размер время x БВС x 3.');
end

if ~isnumeric(rezultat_kinematiki.skorosti) ...
        || ndims(rezultat_kinematiki.skorosti) ~= 3 ...
        || size(rezultat_kinematiki.skorosti, 3) ~= 3
    error('%s', 'Поле skorosti результата кинематики должно иметь размер время x БВС x 3.');
end

if size(rezultat_kinematiki.polozheniya, 1) ~= numel(rezultat_kinematiki.vremya) ...
        || size(rezultat_kinematiki.skorosti, 1) ~= numel(rezultat_kinematiki.vremya)
    error('%s', 'Размеры временной оси результата кинематики заданы некорректно.');
end

if size(rezultat_kinematiki.polozheniya, 2) ~= rezultat_kinematiki.chislo_bvs ...
        || size(rezultat_kinematiki.skorosti, 2) ~= rezultat_kinematiki.chislo_bvs ...
        || numel(rezultat_kinematiki.id_bvs) ~= rezultat_kinematiki.chislo_bvs
    error('%s', 'Число БВС в результате кинематики не согласовано между полями.');
end

if ~all(isfinite(rezultat_kinematiki.polozheniya(:))) ...
        || ~all(isfinite(rezultat_kinematiki.skorosti(:)))
    error('%s', 'Результат кинематики должен содержать только конечные положения и скорости.');
end
end

function sostoyaniya_bvs = sostavit_sostoyaniya_iz_rezultata(rezultat_kinematiki, nomer_momenta)

if ~isnumeric(nomer_momenta) ...
        || ~isscalar(nomer_momenta) ...
        || nomer_momenta < 1 ...
        || nomer_momenta > numel(rezultat_kinematiki.vremya)
    error('%s', 'Номер момента времени для построения состояний БВС задан некорректно.');
end

chislo_bvs = rezultat_kinematiki.chislo_bvs;
sostoyaniya_bvs = repmat(struct( ...
    'id_bvs', '', ...
    'rol', '', ...
    'polozhenie', zeros(1, 3), ...
    'skorost', zeros(1, 3), ...
    'zapas_energii', 0, ...
    'rabotosposoben', true), 1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
    sostoyanie = struct();
    sostoyanie.id_bvs = rezultat_kinematiki.id_bvs{nomer_bvs};
    sostoyanie.rol = 'iz_rezultata_kinematiki';
    sostoyanie.polozhenie = reshape( ...
        rezultat_kinematiki.polozheniya(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyanie.skorost = reshape( ...
        rezultat_kinematiki.skorosti(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyanie.zapas_energii = 0;
    sostoyanie.rabotosposoben = true;
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyanie);
end
end

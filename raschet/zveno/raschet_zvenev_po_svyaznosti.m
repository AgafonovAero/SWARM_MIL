function rezultat = raschet_zvenev_po_svyaznosti(rezultat_svyaznosti, parametry_zvenev)

if nargin < 2
    error('%s', [ ...
        'Для расчета звеньев по связности требуются результат связности ' ...
        'и параметры звеньев.' ...
        ]);
end

parametry_zvenev = proverit_parametry_zvenev(parametry_zvenev);
proverit_rezultat_svyaznosti(rezultat_svyaznosti);

chislo_momentov = numel(rezultat_svyaznosti.vremya);
zvenya_po_vremeni = cell(1, chislo_momentov);
golovnye_bvs_po_vremeni = cell(1, chislo_momentov);
pokazateli_po_vremeni = [];
chislo_zvenev = zeros(1, chislo_momentov);
dolya_odinochnyh_zvenev = zeros(1, chislo_momentov);

for nomer_momenta = 1:chislo_momentov
    graf_svyaznosti = poluchit_graf_po_vremeni(rezultat_svyaznosti, nomer_momenta);
    sostoyaniya_bvs = sostavit_sostoyaniya_po_svyaznosti( ...
        graf_svyaznosti, rezultat_svyaznosti);
    rezultat_zvenev = sformirovat_zvenya_po_grafu( ...
        graf_svyaznosti, ...
        sostoyaniya_bvs, ...
        parametry_zvenev);
    rezultat_golovnyh = naznachit_golovnye_bvs( ...
        rezultat_zvenev, ...
        graf_svyaznosti, ...
        sostoyaniya_bvs, ...
        parametry_zvenev);
    pokazateli = otsenit_zvenya( ...
        rezultat_zvenev, ...
        rezultat_golovnyh, ...
        graf_svyaznosti);

    zvenya_po_vremeni{nomer_momenta} = rezultat_golovnyh.zvenya;
    golovnye_bvs_po_vremeni{nomer_momenta} = rezultat_golovnyh.golovnye_bvs;

    if isempty(pokazateli_po_vremeni)
        pokazateli_po_vremeni = repmat(pokazateli, 1, chislo_momentov);
    end

    pokazateli_po_vremeni(nomer_momenta) = pokazateli;
    chislo_zvenev(nomer_momenta) = rezultat_zvenev.chislo_zvenev;

    if rezultat_zvenev.chislo_zvenev == 0
        dolya_odinochnyh_zvenev(nomer_momenta) = 0;
    else
        dolya_odinochnyh_zvenev(nomer_momenta) = ...
            rezultat_zvenev.chislo_odinochnyh_zvenev ...
            / rezultat_zvenev.chislo_zvenev;
    end
end

rezultat = struct();
rezultat.id_scenariya = char(string(rezultat_svyaznosti.id_scenariya));
rezultat.vremya = rezultat_svyaznosti.vremya;
rezultat.zvenya_po_vremeni = zvenya_po_vremeni;
rezultat.golovnye_bvs_po_vremeni = golovnye_bvs_po_vremeni;
rezultat.pokazateli_po_vremeni = pokazateli_po_vremeni;
rezultat.srednee_chislo_zvenev = mean(chislo_zvenev);
rezultat.srednyaya_dolya_odinochnyh_zvenev = mean(dolya_odinochnyh_zvenev);
rezultat.primechanie = [ ...
    'Звенья рассчитаны по готовому графу связности без маршрутизации, ' ...
    'управления, обучения и изменения траекторий БВС.' ...
    ];
end

function proverit_rezultat_svyaznosti(rezultat_svyaznosti)
if ~isstruct(rezultat_svyaznosti)
    error('%s', ...
        'Результат связности должен быть передан в виде структуры.');
end

obyazatelnye_polya = {
    'id_scenariya'
    'vremya'
    'id_bvs'
    'grafy_po_vremeni'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_svyaznosti, imya_polya)
        error('%s', sprintf( ...
            'В результате связности отсутствует обязательное поле %s.', ...
            imya_polya));
    end
end

if numel(rezultat_svyaznosti.vremya) ~= numel(rezultat_svyaznosti.grafy_po_vremeni)
    error('%s', [ ...
        'Число моментов времени не совпадает с числом графов связности ' ...
        'во времени.' ...
        ]);
end
end

function graf_svyaznosti = poluchit_graf_po_vremeni(rezultat_svyaznosti, nomer_momenta)
grafy_po_vremeni = rezultat_svyaznosti.grafy_po_vremeni;

if iscell(grafy_po_vremeni)
    graf_svyaznosti = grafy_po_vremeni{nomer_momenta};
else
    graf_svyaznosti = grafy_po_vremeni(nomer_momenta);
end
end

function sostoyaniya_bvs = sostavit_sostoyaniya_po_svyaznosti(graf_svyaznosti, rezultat_svyaznosti)

id_bvs = normalizovat_id_bvs(graf_svyaznosti.id_bvs);
chislo_bvs = numel(id_bvs);
zapasy_energii = poluchit_zapasy_energii(rezultat_svyaznosti, chislo_bvs);

sostoyaniya_bvs = repmat(struct( ...
    'id_bvs', '', ...
    'rol', 'iz_rezultata_svyaznosti', ...
    'polozhenie', zeros(1, 3), ...
    'skorost', zeros(1, 3), ...
    'zapas_energii', 0, ...
    'rabotosposoben', true), 1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
    sostoyaniya_bvs(nomer_bvs).id_bvs = id_bvs{nomer_bvs};
    sostoyaniya_bvs(nomer_bvs).zapas_energii = zapasy_energii(nomer_bvs);
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));
end
end

function zapasy_energii = poluchit_zapasy_energii(rezultat_svyaznosti, chislo_bvs)
if isfield(rezultat_svyaznosti, 'zapas_energii_po_bvs')
    zapasy_energii = double(rezultat_svyaznosti.zapas_energii_po_bvs);
    if numel(zapasy_energii) ~= chislo_bvs || any(~isfinite(zapasy_energii))
        error('%s', [ ...
            'Поле zapas_energii_po_bvs в результате связности имеет ' ...
            'некорректный размер или содержит нечисловые значения.' ...
            ]);
    end
else
    zapasy_energii = zeros(1, chislo_bvs);
end
end

function id_bvs = normalizovat_id_bvs(id_bvs)
if isstring(id_bvs)
    id_bvs = cellstr(id_bvs(:).');
elseif ischar(id_bvs)
    id_bvs = {id_bvs};
elseif ~iscell(id_bvs)
    error('%s', 'Идентификаторы БВС должны быть заданы списком строк.');
end

id_bvs = cellfun(@(znachenie) char(string(znachenie)), ...
    id_bvs, 'UniformOutput', false);
end

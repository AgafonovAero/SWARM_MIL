function rezultat = naznachit_golovnye_bvs(rezultat_zvenev, graf_svyaznosti, sostoyaniya_bvs, parametry_zvenev)

if nargin < 4
    error('%s', [ ...
        'Для назначения головных БВС требуются результат звеньев, ' ...
        'граф связности, состояния БВС и параметры звеньев.' ...
        ]);
end

parametry_zvenev = proverit_parametry_zvenev(parametry_zvenev);
proverit_rezultat_zvenev(rezultat_zvenev);

zvenya_s_golovnymi = rezultat_zvenev.zvenya;
golovnye_bvs = cell(1, numel(zvenya_s_golovnymi));
ocenki_kandidatov = cell(1, numel(zvenya_s_golovnymi));

for nomer_zvena = 1:numel(zvenya_s_golovnymi)
    [id_golovnogo_bvs, ocenki] = vybrat_golovnoi_bvs( ...
        zvenya_s_golovnymi(nomer_zvena).id_bvs, ...
        graf_svyaznosti, ...
        sostoyaniya_bvs, ...
        parametry_zvenev);
    zvenya_s_golovnymi(nomer_zvena).golovnoi_bvs = id_golovnogo_bvs;
    golovnye_bvs{nomer_zvena} = id_golovnogo_bvs;
    ocenki_kandidatov{nomer_zvena} = ocenki;
end

rezultat = struct();
rezultat.id_bvs = rezultat_zvenev.id_bvs;
rezultat.zvenya = zvenya_s_golovnymi;
rezultat.golovnye_bvs = golovnye_bvs;
rezultat.ocenki_kandidatov = ocenki_kandidatov;
rezultat.primechanie = [ ...
    'Головные БВС выбраны по внутреннему расчетному правилу проекта ' ...
    'без управления движением и маршрутизации.' ...
    ];
end

function proverit_rezultat_zvenev(rezultat_zvenev)
if ~isstruct(rezultat_zvenev) || ~isfield(rezultat_zvenev, 'zvenya')
    error('%s', [ ...
        'Для назначения головных БВС требуется структура результата ' ...
        'формирования звеньев.' ...
        ]);
end

if isempty(rezultat_zvenev.zvenya)
    error('%s', 'В результате формирования звеньев отсутствуют звенья.');
end
end

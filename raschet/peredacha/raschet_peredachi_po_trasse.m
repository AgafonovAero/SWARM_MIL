function rezultat = raschet_peredachi_po_trasse(scenarii, rezultat_kinematiki, rezultat_svyaznosti, rezultat_zvenev, parametry_peredachi)
if nargin < 5
    error('%s', [ ...
        'Для расчета передачи по трассе требуются сценарий, результат кинематики, ' ...
        'результат связности, результат звеньев и параметры передачи.' ...
        ]);
end

proverit_scenarii(scenarii, 'структура сценария для расчета передачи');
rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki);
rezultat_svyaznosti = proverit_rezultat_svyaznosti(rezultat_svyaznosti);
rezultat_zvenev = proverit_rezultat_zvenev(rezultat_zvenev);
parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);

soobshcheniya = sozdat_nachalnye_soobshcheniya(scenarii, parametry_peredachi);
ocheredi_bvs = sozdat_ocheredi_bvs( ...
    rezultat_kinematiki.id_bvs, ...
    soobshcheniya, ...
    parametry_peredachi);
zhurnal_sobytii = struct([]);

for nomer_momenta = 1:numel(rezultat_kinematiki.vremya)
    sostoyaniya_bvs = sostavit_sostoyaniya_dlya_momenta( ...
        rezultat_kinematiki, ...
        scenarii, ...
        nomer_momenta);
    graf_svyaznosti = poluchit_graf_po_vremeni( ...
        rezultat_svyaznosti, ...
        nomer_momenta);
    dannye_zvenev = poluchit_dannye_zvenev_po_vremeni( ...
        rezultat_zvenev, ...
        nomer_momenta);

    [ocheredi_bvs, sobytiya_shaga] = vypolnit_shag_peredachi( ...
        ocheredi_bvs, ...
        graf_svyaznosti, ...
        sostoyaniya_bvs, ...
        dannye_zvenev, ...
        rezultat_kinematiki.vremya(nomer_momenta), ...
        parametry_peredachi);

    zhurnal_sobytii = dobavit_sobytiya(zhurnal_sobytii, sobytiya_shaga);
    soobshcheniya = obnovit_soobshcheniya_po_sobytiyam( ...
        soobshcheniya, ...
        sobytiya_shaga);
end

pokazateli = otsenit_peredachu(struct( ...
    'soobshcheniya', soobshcheniya, ...
    'zhurnal_sobytii', zhurnal_sobytii));

rezultat = struct();
rezultat.id_scenariya = char(string(scenarii.id_scenariya));
rezultat.vremya = rezultat_kinematiki.vremya;
rezultat.soobshcheniya = soobshcheniya;
rezultat.zhurnal_sobytii = zhurnal_sobytii;
rezultat.chislo_soobshchenii = pokazateli.chislo_soobshchenii;
rezultat.chislo_dostavlennyh = pokazateli.chislo_dostavlennyh;
rezultat.chislo_poteryannyh = pokazateli.chislo_poteryannyh;
rezultat.dolya_dostavlennyh = pokazateli.dolya_dostavlennyh;
rezultat.srednyaya_zaderzhka_dostavki_s = ...
    pokazateli.srednyaya_zaderzhka_dostavki_s;
rezultat.srednee_chislo_peresylok = ...
    pokazateli.srednee_chislo_peresylok;
rezultat.maksimalnoe_chislo_peresylok = ...
    pokazateli.maksimalnoe_chislo_peresylok;
rezultat.primechanie = [ ...
    'Передача сообщений рассчитана по готовым результатам кинематики, связности и ' ...
    'звеньев без изменения движения БВС, без обучения и без моделей Simulink.' ...
    ];
end

function rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki)
obyazatelnye_polya = {
    'id_scenariya'
    'vremya'
    'id_bvs'
    'polozheniya'
    'skorosti'
    'chislo_bvs'
    };

if ~isstruct(rezultat_kinematiki)
    error('%s', ...
        'Результат кинематики должен быть структурой.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_kinematiki, imya_polya)
        error('%s', sprintf( ...
            'В результате кинематики отсутствует поле %s.', ...
            imya_polya));
    end
end
end

function rezultat_svyaznosti = proverit_rezultat_svyaznosti(rezultat_svyaznosti)
if ~isstruct(rezultat_svyaznosti) ...
        || ~isfield(rezultat_svyaznosti, 'grafy_po_vremeni') ...
        || ~isfield(rezultat_svyaznosti, 'vremya')
    error('%s', ...
        'Результат связности должен содержать графы по времени и временную ось.');
end
end

function rezultat_zvenev = proverit_rezultat_zvenev(rezultat_zvenev)
if ~isstruct(rezultat_zvenev) ...
        || ~isfield(rezultat_zvenev, 'zvenya_po_vremeni') ...
        || ~isfield(rezultat_zvenev, 'golovnye_bvs_po_vremeni')
    error('%s', ...
        'Результат звеньев должен содержать звенья и головные БВС по времени.');
end
end

function sostoyaniya_bvs = sostavit_sostoyaniya_dlya_momenta(rezultat_kinematiki, scenarii, nomer_momenta)
chislo_bvs = rezultat_kinematiki.chislo_bvs;
sostoyaniya_bvs = sozdat_sostoyanie_bvs_iz_scenariya(scenarii);

for nomer_bvs = 1:chislo_bvs
    sostoyaniya_bvs(nomer_bvs).polozhenie = reshape( ...
        rezultat_kinematiki.polozheniya(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyaniya_bvs(nomer_bvs).skorost = reshape( ...
        rezultat_kinematiki.skorosti(nomer_momenta, nomer_bvs, :), ...
        1, 3);
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs( ...
        sostoyaniya_bvs(nomer_bvs));
end
end

function graf_svyaznosti = poluchit_graf_po_vremeni(rezultat_svyaznosti, nomer_momenta)
if iscell(rezultat_svyaznosti.grafy_po_vremeni)
    graf_svyaznosti = rezultat_svyaznosti.grafy_po_vremeni{nomer_momenta};
else
    graf_svyaznosti = rezultat_svyaznosti.grafy_po_vremeni(nomer_momenta);
end
end

function dannye_zvenev = poluchit_dannye_zvenev_po_vremeni(rezultat_zvenev, nomer_momenta)
dannye_zvenev = struct();
dannye_zvenev.zvenya = rezultat_zvenev.zvenya_po_vremeni{nomer_momenta};
dannye_zvenev.golovnye_bvs = ...
    rezultat_zvenev.golovnye_bvs_po_vremeni{nomer_momenta};
end

function zhurnal_sobytii = dobavit_sobytiya(zhurnal_sobytii, sobytiya_shaga)
if isempty(sobytiya_shaga)
    return
end

if isempty(zhurnal_sobytii)
    zhurnal_sobytii = sobytiya_shaga;
else
    zhurnal_sobytii = [zhurnal_sobytii, sobytiya_shaga]; %#ok<AGROW>
end
end

function soobshcheniya = obnovit_soobshcheniya_po_sobytiyam(soobshcheniya, sobytiya_shaga)
if isempty(sobytiya_shaga)
    return
end

for nomer_sobytiya = 1:numel(sobytiya_shaga)
    id_soobshcheniya = sobytiya_shaga(nomer_sobytiya).id_soobshcheniya;
    indeks_soobshcheniya = nayti_soobshchenie(soobshcheniya, id_soobshcheniya);
    soobshcheniya(indeks_soobshcheniya) = ...
        sobytiya_shaga(nomer_sobytiya).soobshchenie;
end
end

function indeks_soobshcheniya = nayti_soobshchenie(soobshcheniya, id_soobshcheniya)
indeks_soobshcheniya = 0;
for nomer_soobshcheniya = 1:numel(soobshcheniya)
    if strcmp(soobshcheniya(nomer_soobshcheniya).id_soobshcheniya, ...
            id_soobshcheniya)
        indeks_soobshcheniya = nomer_soobshcheniya;
        break
    end
end

if indeks_soobshcheniya == 0
    error('%s', sprintf( ...
        'Не найдено сообщение %s для обновления результата передачи.', ...
        id_soobshcheniya));
end
end

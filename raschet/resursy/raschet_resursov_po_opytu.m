function rezultat_resursov = raschet_resursov_po_opytu(rezultat_opyta, parametry_resursov)
if nargin < 2
    error('%s', [ ...
        'Для расчета ресурсов по опыту требуются результат опыта ' ...
        'и параметры ресурсов.' ...
        ]);
end

parametry_resursov = proverit_parametry_resursov(parametry_resursov);
rezultat_opyta = proverit_rezultat_opyta(rezultat_opyta);

rezultat_dvizheniya = raschet_energii_dvizheniya( ...
    rezultat_opyta.kinematika, ...
    parametry_resursov);
rezultat_peredachi = raschet_resursov_peredachi( ...
    rezultat_opyta.peredacha, ...
    parametry_resursov);
nagruzka_golovnyh_bvs = raschet_nagruzki_golovnyh_bvs( ...
    rezultat_opyta.zvenya, ...
    rezultat_opyta.peredacha);

id_bvs = rezultat_opyta.kinematika.id_bvs;
chislo_bvs = numel(id_bvs);
chislo_momentov = numel(rezultat_opyta.kinematika.vremya);

nachalnaya_energiya = opredelit_nachalnuyu_energiyu( ...
    rezultat_opyta, ...
    parametry_resursov, ...
    id_bvs);
energii_dvizheniya = rezultat_dvizheniya.rashod_dvizheniya_po_vremeni_dzh;
matrica_peredannyh_bit = sootnesti_po_id_bvs( ...
    rezultat_peredachi.id_bvs, ...
    rezultat_peredachi.chislo_peredannyh_bit_po_vremeni, ...
    id_bvs, ...
    chislo_momentov);
matrica_prinyatyh_bit = sootnesti_po_id_bvs( ...
    rezultat_peredachi.id_bvs, ...
    rezultat_peredachi.chislo_prinyatyh_bit_po_vremeni, ...
    id_bvs, ...
    chislo_momentov);
matrica_obrabotannyh_soobshchenii = sootnesti_po_id_bvs( ...
    rezultat_peredachi.id_bvs, ...
    rezultat_peredachi.chislo_obrabotannyh_soobshchenii_po_vremeni, ...
    id_bvs, ...
    chislo_momentov);

energii_peredachi = matrica_peredannyh_bit ...
    * parametry_resursov.zatraty_peredachi_dzh_na_bit;
energii_priema = matrica_prinyatyh_bit ...
    * parametry_resursov.zatraty_priema_dzh_na_bit;
energii_obrabotki = matrica_obrabotannyh_soobshchenii ...
    * parametry_resursov.nagruzka_obrabotki_soobshcheniya_operacii ...
    * parametry_resursov.zatraty_obrabotki_dzh_na_operaciyu;
vychislitelnaya_nagruzka = matrica_obrabotannyh_soobshchenii ...
    * parametry_resursov.nagruzka_obrabotki_soobshcheniya_operacii ...
    / parametry_resursov.vychislitelnaya_moshchnost_operacii_v_s;
nagruzka_svyazi = sootnesti_nagruzku_svyazi( ...
    matrica_peredannyh_bit, ...
    rezultat_opyta.svyaznost, ...
    id_bvs, ...
    chislo_momentov);
zanyatost_ocheredei = rasschitat_zanyatost_ocheredei( ...
    rezultat_opyta, ...
    id_bvs, ...
    chislo_momentov);

summarnyi_rashod_po_vremeni = energii_dvizheniya ...
    + energii_peredachi ...
    + energii_priema ...
    + energii_obrabotki;
energiya_po_vremeni = max(0, ...
    nachalnaya_energiya - cumsum(summarnyi_rashod_po_vremeni, 1));
energiya_ostatok_itog = energiya_po_vremeni(end, :);
dolya_bvs_s_dostatochnoi_energiey = mean( ...
    energiya_ostatok_itog >= parametry_resursov.energiya_minimalnaya_dzh);

sostoyaniya_resursov = repmat(struct( ...
    'id_bvs', '', ...
    'energiya_ostatok_dzh', 0, ...
    'vychislitelnaya_nagruzka', 0, ...
    'nagruzka_svyazi', 0, ...
    'zanyatost_ocheredi', 0, ...
    'chislo_obrabotannyh_soobshchenii', 0, ...
    'chislo_peredannyh_bit', 0, ...
    'yavlyaetsya_golovnym_bvs', false, ...
    'rabotosposoben_po_resursam', true), ...
    1, chislo_bvs);

otnositelnaya_nagruzka_golovnyh = sootnesti_vektor_po_id_bvs( ...
    nagruzka_golovnyh_bvs.id_bvs, ...
    nagruzka_golovnyh_bvs.otnositelnaya_nagruzka_golovnogo_bvs, ...
    id_bvs);

for nomer_bvs = 1:chislo_bvs
    sostoyaniya_resursov(nomer_bvs).id_bvs = id_bvs{nomer_bvs};
    sostoyaniya_resursov(nomer_bvs).energiya_ostatok_dzh = ...
        energiya_ostatok_itog(nomer_bvs);
    sostoyaniya_resursov(nomer_bvs).vychislitelnaya_nagruzka = ...
        mean(vychislitelnaya_nagruzka(:, nomer_bvs));
    sostoyaniya_resursov(nomer_bvs).nagruzka_svyazi = ...
        mean(nagruzka_svyazi(:, nomer_bvs));
    sostoyaniya_resursov(nomer_bvs).zanyatost_ocheredi = ...
        zanyatost_ocheredei.srednyaya_zanyatost(nomer_bvs);
    sostoyaniya_resursov(nomer_bvs).chislo_obrabotannyh_soobshchenii = ...
        sum(matrica_obrabotannyh_soobshchenii(:, nomer_bvs));
    sostoyaniya_resursov(nomer_bvs).chislo_peredannyh_bit = ...
        sum(matrica_peredannyh_bit(:, nomer_bvs));
    sostoyaniya_resursov(nomer_bvs).yavlyaetsya_golovnym_bvs = ...
        any(strcmp(nagruzka_golovnyh_bvs.id_bvs, id_bvs{nomer_bvs}) ...
        & nagruzka_golovnyh_bvs.chislo_momentov_golovnogo_bvs > 0);
    sostoyaniya_resursov(nomer_bvs).rabotosposoben_po_resursam = ...
        proverit_rabotosposobnost_po_resursam( ...
        energiya_ostatok_itog(nomer_bvs), ...
        zanyatost_ocheredei.maksimalnaya_zanyatost(nomer_bvs), ...
        parametry_resursov);
end

rezultat_resursov = struct();
rezultat_resursov.id_scenariya = char(string(rezultat_opyta.id_scenariya));
rezultat_resursov.id_varianta = poluchit_pole_ili_pustuyu_stroku( ...
    rezultat_opyta, ...
    'id_varianta');
rezultat_resursov.id_bvs = id_bvs;
rezultat_resursov.vremya = rezultat_opyta.kinematika.vremya;
rezultat_resursov.parametry_resursov = parametry_resursov;
rezultat_resursov.energiya_po_vremeni = energiya_po_vremeni;
rezultat_resursov.energiya_ostatok_itog = energiya_ostatok_itog;
rezultat_resursov.rashod_energii_dvizhenie = sum(energii_dvizheniya, 1);
rezultat_resursov.rashod_energii_peredacha = sum(energii_peredachi, 1);
rezultat_resursov.rashod_energii_priem = sum(energii_priema, 1);
rezultat_resursov.rashod_energii_obrabotka = sum(energii_obrabotki, 1);
rezultat_resursov.vychislitelnaya_nagruzka_po_vremeni = vychislitelnaya_nagruzka;
rezultat_resursov.nagruzka_svyazi_po_vremeni = nagruzka_svyazi;
rezultat_resursov.zanyatost_ocheredei = zanyatost_ocheredei;
rezultat_resursov.nagruzka_golovnyh_bvs = nagruzka_golovnyh_bvs;
rezultat_resursov.sostoyaniya_resursov_bvs = sostoyaniya_resursov;
rezultat_resursov.dolya_bvs_s_dostatochnoi_energiey = ...
    dolya_bvs_s_dostatochnoi_energiey;
rezultat_resursov.maksimalnaya_nagruzka_golovnogo_bvs = ...
    max(otnositelnaya_nagruzka_golovnyh);
rezultat_resursov.primechanie = [ ...
    'Ресурсная сводка рассчитана поверх результатов одного опыта без ' ...
    'изменения траекторий, передачи и законов управления.' ...
    ];
end

function rezultat_opyta = proverit_rezultat_opyta(rezultat_opyta)
obyazatelnye_polya = {
    'id_scenariya'
    'kinematika'
    'svyaznost'
    'zvenya'
    'peredacha'
    };

if ~isstruct(rezultat_opyta)
    error('%s', ...
        'Результат опыта для расчета ресурсов должен быть структурой.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_opyta, imya_polya)
        error('%s', sprintf( ...
            'В результате опыта отсутствует поле %s.', ...
            imya_polya));
    end
end
end

function nachalnaya_energiya = opredelit_nachalnuyu_energiyu(rezultat_opyta, parametry_resursov, id_bvs)
nachalnaya_energiya = parametry_resursov.energiya_start_dzh * ones(1, numel(id_bvs));

if ~isfield(rezultat_opyta, 'scenarii') || ~isstruct(rezultat_opyta.scenarii) ...
        || ~isfield(rezultat_opyta.scenarii, 'sostav_roya') ...
        || ~isfield(rezultat_opyta.scenarii.sostav_roya, 'bvs')
    return
end

spisok_bvs = rezultat_opyta.scenarii.sostav_roya.bvs;
for nomer_bvs = 1:numel(spisok_bvs)
    id = char(string(spisok_bvs(nomer_bvs).id_bvs));
    indeks = find(strcmp(id_bvs, id), 1);
    if isempty(indeks)
        continue
    end

    energiya = double(spisok_bvs(nomer_bvs).zapas_energii);
    if isfinite(energiya) && energiya >= 0
        nachalnaya_energiya(indeks) = energiya;
    end
end
end

function zanyatost = rasschitat_zanyatost_ocheredei(rezultat_opyta, id_bvs, chislo_momentov)
if isfield(rezultat_opyta, 'parametry_peredachi')
    maksimalnyi_razmer_ocheredi = ...
        rezultat_opyta.parametry_peredachi.maksimalnyi_razmer_ocheredi;
else
    maksimalnyi_razmer_ocheredi = ...
        parametry_peredachi_po_umolchaniyu().maksimalnyi_razmer_ocheredi;
end

kolichestvo_ozhidaniy = zeros(chislo_momentov, numel(id_bvs));
zhurnal_sobytii = rezultat_opyta.peredacha.zhurnal_sobytii;

for nomer_sobytiya = 1:numel(zhurnal_sobytii)
    sobytie = zhurnal_sobytii(nomer_sobytiya);
    if ~strcmp(sobytie.tip_sobytiya, 'ozhidaet')
        continue
    end

    indeks_vremeni = nayti_indeks_vremeni( ...
        rezultat_opyta.peredacha.vremya, ...
        sobytie.vremya_sobytiya);
    indeks_bvs = nayti_indeks_bvs(id_bvs, sobytie.id_tekushchego_bvs);
    kolichestvo_ozhidaniy(indeks_vremeni, indeks_bvs) = ...
        kolichestvo_ozhidaniy(indeks_vremeni, indeks_bvs) + 1;
end

dolya_zanyatosti = min(1, kolichestvo_ozhidaniy / max(1, maksimalnyi_razmer_ocheredi));

zanyatost = struct();
zanyatost.id_bvs = id_bvs;
zanyatost.vremya = rezultat_opyta.peredacha.vremya;
zanyatost.dolya_zanyatosti_po_vremeni = dolya_zanyatosti;
zanyatost.srednyaya_zanyatost = mean(dolya_zanyatosti, 1);
zanyatost.maksimalnaya_zanyatost = max(dolya_zanyatosti, [], 1);
end

function matritsa = sootnesti_po_id_bvs(id_istochnika, znacheniya, id_celevye, chislo_momentov)
matritsa = zeros(chislo_momentov, numel(id_celevye));
for nomer_bvs = 1:numel(id_istochnika)
    indeks = find(strcmp(id_celevye, id_istochnika{nomer_bvs}), 1);
    if isempty(indeks)
        continue
    end
    matritsa(:, indeks) = znacheniya(:, nomer_bvs);
end
end

function nagruzka_svyazi = sootnesti_nagruzku_svyazi(matrica_peredannyh_bit, rezultat_svyaznosti, id_bvs, chislo_momentov)
nagruzka_svyazi = zeros(chislo_momentov, numel(id_bvs));

for nomer_momenta = 1:chislo_momentov
    graf = rezultat_svyaznosti.grafy_po_vremeni(nomer_momenta);
    for nomer_bvs = 1:numel(id_bvs)
        indeks_grafa = find(strcmp(graf.id_bvs, id_bvs{nomer_bvs}), 1);
        if isempty(indeks_grafa)
            continue
        end

        propusknaya_sposobnost = sum( ...
            graf.matrica_propusknoy_sposobnosti_bit_s(indeks_grafa, :));
        if propusknaya_sposobnost > 0
            nagruzka_svyazi(nomer_momenta, nomer_bvs) = min( ...
                1, matrica_peredannyh_bit(nomer_momenta, nomer_bvs) / propusknaya_sposobnost);
        end
    end
end
end

function vektor = sootnesti_vektor_po_id_bvs(id_istochnika, znacheniya, id_celevye)
vektor = zeros(1, numel(id_celevye));
for nomer_bvs = 1:numel(id_istochnika)
    indeks = find(strcmp(id_celevye, id_istochnika{nomer_bvs}), 1);
    if isempty(indeks)
        continue
    end
    vektor(indeks) = znacheniya(nomer_bvs);
end
end

function rezultat = proverit_rabotosposobnost_po_resursam(energiya_ostatok, maksimalnaya_zanyatost, parametry_resursov)
rezultat = true;

if parametry_resursov.uchityvat_ogranichenie_energii
    rezultat = rezultat && ...
        energiya_ostatok >= parametry_resursov.energiya_minimalnaya_dzh;
end

if parametry_resursov.uchityvat_ogranichenie_ocheredi
    rezultat = rezultat && ...
        maksimalnaya_zanyatost <= ...
        parametry_resursov.maksimalnaya_dolya_zanyatosti_ocheredi;
end
end

function indeks = nayti_indeks_vremeni(vremya, znachenie_vremeni)
indeks = find(abs(vremya - znachenie_vremeni) <= 1e-9, 1);
if isempty(indeks)
    error('%s', sprintf( ...
        'Событие с временем %g отсутствует на оси времени опыта.', ...
        znachenie_vremeni));
end
end

function indeks = nayti_indeks_bvs(id_bvs, iskomyi_id)
indeks = find(strcmp(id_bvs, char(string(iskomyi_id))), 1);
if isempty(indeks)
    error('%s', sprintf( ...
        'Не найден идентификатор БВС %s в расчете ресурсов.', ...
        char(string(iskomyi_id))));
end
end

function znachenie = poluchit_pole_ili_pustuyu_stroku(struktura, imya_polya)
if isfield(struktura, imya_polya)
    znachenie = char(string(struktura.(imya_polya)));
else
    znachenie = '';
end
end

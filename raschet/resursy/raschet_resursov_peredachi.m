function resursy_peredachi = raschet_resursov_peredachi(rezultat_peredachi, parametry_resursov)
if nargin < 2
    error('%s', [ ...
        'Для расчета ресурсов передачи требуются результат передачи ' ...
        'и параметры ресурсов.' ...
        ]);
end

parametry_resursov = proverit_parametry_resursov(parametry_resursov);
rezultat_peredachi = proverit_rezultat_peredachi(rezultat_peredachi);

id_bvs = sobrat_id_bvs(rezultat_peredachi);
chislo_bvs = numel(id_bvs);
chislo_momentov = numel(rezultat_peredachi.vremya);

peredannye_bity = zeros(chislo_momentov, chislo_bvs);
prinyatye_bity = zeros(chislo_momentov, chislo_bvs);
obrabotannye_soobshcheniya = zeros(chislo_momentov, chislo_bvs);

for nomer_sobytiya = 1:numel(rezultat_peredachi.zhurnal_sobytii)
    sobytie = rezultat_peredachi.zhurnal_sobytii(nomer_sobytiya);
    indeks_vremeni = nayti_indeks_vremeni( ...
        rezultat_peredachi.vremya, ...
        sobytie.vremya_sobytiya);

    if strlength(string(sobytie.id_tekushchego_bvs)) > 0
        indeks_bvs = nayti_indeks_bvs(id_bvs, sobytie.id_tekushchego_bvs);
        obrabotannye_soobshcheniya(indeks_vremeni, indeks_bvs) = ...
            obrabotannye_soobshcheniya(indeks_vremeni, indeks_bvs) + 1;
    end

    est_peredacha = any(strcmp(sobytie.tip_sobytiya, { ...
        'peredano', ...
        'dostavleno', ...
        'poteryano_iz_za_perepolneniya_ocheredi'}));
    est_sleduyushchii_bvs = strlength(string(sobytie.id_sleduyushchego_bvs)) > 0;
    razmer_bit = double(sobytie.soobshchenie.razmer_bit);

    if est_peredacha && est_sleduyushchii_bvs ...
            && ~strcmp(sobytie.id_tekushchego_bvs, sobytie.id_sleduyushchego_bvs)
        indeks_otpravitelya = nayti_indeks_bvs(id_bvs, sobytie.id_tekushchego_bvs);
        indeks_poluchatelya = nayti_indeks_bvs(id_bvs, sobytie.id_sleduyushchego_bvs);
        peredannye_bity(indeks_vremeni, indeks_otpravitelya) = ...
            peredannye_bity(indeks_vremeni, indeks_otpravitelya) + razmer_bit;
        prinyatye_bity(indeks_vremeni, indeks_poluchatelya) = ...
            prinyatye_bity(indeks_vremeni, indeks_poluchatelya) + razmer_bit;
    end
end

chislo_operaciy = obrabotannye_soobshcheniya ...
    * parametry_resursov.nagruzka_obrabotki_soobshcheniya_operacii;
energiya_peredachi_po_vremeni = peredannye_bity ...
    * parametry_resursov.zatraty_peredachi_dzh_na_bit;
energiya_priema_po_vremeni = prinyatye_bity ...
    * parametry_resursov.zatraty_priema_dzh_na_bit;
energiya_obrabotki_po_vremeni = chislo_operaciy ...
    * parametry_resursov.zatraty_obrabotki_dzh_na_operaciyu;

resursy_peredachi = struct();
resursy_peredachi.id_bvs = id_bvs;
resursy_peredachi.vremya = rezultat_peredachi.vremya;
resursy_peredachi.chislo_peredannyh_bit_po_vremeni = peredannye_bity;
resursy_peredachi.chislo_prinyatyh_bit_po_vremeni = prinyatye_bity;
resursy_peredachi.chislo_obrabotannyh_soobshchenii_po_vremeni = ...
    obrabotannye_soobshcheniya;
resursy_peredachi.chislo_peredannyh_bit = sum(peredannye_bity, 1);
resursy_peredachi.energiya_peredachi_dzh = sum(energiya_peredachi_po_vremeni, 1);
resursy_peredachi.energiya_priema_dzh = sum(energiya_priema_po_vremeni, 1);
resursy_peredachi.energiya_obrabotki_dzh = sum(energiya_obrabotki_po_vremeni, 1);
resursy_peredachi.chislo_obrabotannyh_soobshchenii = ...
    sum(obrabotannye_soobshcheniya, 1);
resursy_peredachi.primechanie = [ ...
    'Ресурсы передачи рассчитаны по журналу событий сообщений без ' ...
    'изменения маршрутов и очередей предыдущих этапов.' ...
    ];
end

function rezultat_peredachi = proverit_rezultat_peredachi(rezultat_peredachi)
obyazatelnye_polya = {
    'vremya'
    'soobshcheniya'
    'zhurnal_sobytii'
    };

if ~isstruct(rezultat_peredachi)
    error('%s', ...
        'Результат передачи должен быть передан в виде структуры.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_peredachi, imya_polya)
        error('%s', sprintf( ...
            'В результате передачи отсутствует поле %s.', ...
            imya_polya));
    end
end
end

function id_bvs = sobrat_id_bvs(rezultat_peredachi)
id_bvs = {};

for nomer_soobshcheniya = 1:numel(rezultat_peredachi.soobshcheniya)
    soobshchenie = rezultat_peredachi.soobshcheniya(nomer_soobshcheniya);
    id_bvs = dobavit_unikalnoe_znachenie(id_bvs, soobshchenie.id_otpravitelya);
    id_bvs = dobavit_unikalnoe_znachenie(id_bvs, soobshchenie.id_poluchatelya);
    marshrut = soobshchenie.marshrut;
    for nomer_tochki = 1:numel(marshrut)
        id_bvs = dobavit_unikalnoe_znachenie(id_bvs, marshrut{nomer_tochki});
    end
end

for nomer_sobytiya = 1:numel(rezultat_peredachi.zhurnal_sobytii)
    sobytie = rezultat_peredachi.zhurnal_sobytii(nomer_sobytiya);
    id_bvs = dobavit_unikalnoe_znachenie(id_bvs, sobytie.id_tekushchego_bvs);
    id_bvs = dobavit_unikalnoe_znachenie(id_bvs, sobytie.id_sleduyushchego_bvs);
end

if isempty(id_bvs)
    error('%s', ...
        'В результате передачи не найдено ни одного идентификатора БВС.');
end
end

function indeks = nayti_indeks_vremeni(vremya, znachenie_vremeni)
indeks = find(abs(vremya - znachenie_vremeni) <= 1e-9, 1);
if isempty(indeks)
    error('%s', sprintf( ...
        'Событие передачи имеет время %g, отсутствующее на оси времени.', ...
        znachenie_vremeni));
end
end

function indeks = nayti_indeks_bvs(id_bvs, iskomyi_id)
indeks = find(strcmp(id_bvs, char(string(iskomyi_id))), 1);
if isempty(indeks)
    error('%s', sprintf( ...
        'Не найден идентификатор БВС %s в ресурсной сводке передачи.', ...
        char(string(iskomyi_id))));
end
end

function spisok = dobavit_unikalnoe_znachenie(spisok, znachenie)
znachenie = char(string(znachenie));
if strlength(string(znachenie)) == 0
    return
end

if ~any(strcmp(spisok, znachenie))
    spisok{end + 1} = znachenie; %#ok<AGROW>
end
end

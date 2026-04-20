function pokazateli = izvlech_pokazateli_resursov(rezultat_resursov)
if nargin < 1 || ~isstruct(rezultat_resursov)
    error('%s', ...
        'Для извлечения показателей ресурсов требуется структура результата.');
end

obyazatelnye_polya = {
    'energiya_ostatok_itog'
    'rashod_energii_dvizhenie'
    'rashod_energii_peredacha'
    'rashod_energii_priem'
    'rashod_energii_obrabotka'
    'vychislitelnaya_nagruzka_po_vremeni'
    'zanyatost_ocheredei'
    'nagruzka_golovnyh_bvs'
    'dolya_bvs_s_dostatochnoi_energiey'
    'maksimalnaya_nagruzka_golovnogo_bvs'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(rezultat_resursov, imya_polya)
        error('%s', sprintf( ...
            'В результате ресурсов отсутствует поле %s.', ...
            imya_polya));
    end
end

summarnyi_rashod = rezultat_resursov.rashod_energii_dvizhenie ...
    + rezultat_resursov.rashod_energii_peredacha ...
    + rezultat_resursov.rashod_energii_priem ...
    + rezultat_resursov.rashod_energii_obrabotka;

pokazateli = struct();
pokazateli.srednii_ostatok_energii = ...
    mean(rezultat_resursov.energiya_ostatok_itog);
pokazateli.minimalnyi_ostatok_energii = ...
    min(rezultat_resursov.energiya_ostatok_itog);
pokazateli.summarnyi_rashod_energii = sum(summarnyi_rashod);
pokazateli.dolya_bvs_s_dostatochnoi_energiey = ...
    double(rezultat_resursov.dolya_bvs_s_dostatochnoi_energiey);
pokazateli.srednyaya_vychislitelnaya_nagruzka = ...
    mean(rezultat_resursov.vychislitelnaya_nagruzka_po_vremeni, 'all');
pokazateli.maksimalnaya_vychislitelnaya_nagruzka = ...
    max(rezultat_resursov.vychislitelnaya_nagruzka_po_vremeni, [], 'all');
pokazateli.srednyaya_zanyatost_ocheredi = ...
    mean(rezultat_resursov.zanyatost_ocheredei.srednyaya_zanyatost);
pokazateli.maksimalnaya_zanyatost_ocheredi = ...
    max(rezultat_resursov.zanyatost_ocheredei.maksimalnaya_zanyatost);
pokazateli.srednyaya_nagruzka_svyazi = ...
    srednee_znachenie_nagruzki_svyazi(rezultat_resursov);
pokazateli.maksimalnaya_nagruzka_svyazi = ...
    maksimalnoe_znachenie_nagruzki_svyazi(rezultat_resursov);
pokazateli.srednyaya_nagruzka_golovnyh_bvs = ...
    mean(rezultat_resursov.nagruzka_golovnyh_bvs.otnositelnaya_nagruzka_golovnogo_bvs);
pokazateli.maksimalnaya_nagruzka_golovnogo_bvs = ...
    double(rezultat_resursov.maksimalnaya_nagruzka_golovnogo_bvs);
dopustimost = poluchit_dopustimost_resursov(rezultat_resursov);
if ~isempty(dopustimost)
    pokazateli.itog_dopustim = double(dopustimost.itog_dopustim);
    pokazateli.energia_dopustima = double(dopustimost.energia_dopustima);
    pokazateli.vychislitelnaya_nagruzka_dopustima = ...
        double(dopustimost.vychislitelnaya_nagruzka_dopustima);
    pokazateli.ocheredi_dopustimy = double(dopustimost.ocheredi_dopustimy);
    pokazateli.nagruzka_golovnogo_bvs_dopustima = ...
        double(dopustimost.nagruzka_golovnogo_bvs_dopustima);
    pokazateli.nagruzka_svyazi_dopustima = ...
        double(dopustimost.nagruzka_svyazi_dopustima);
    pokazateli.chislo_narushenii = double(numel(dopustimost.narusheniya));
end

proverit_pokazateli(pokazateli);
end

function znachenie = srednee_znachenie_nagruzki_svyazi(rezultat_resursov)
if ~isfield(rezultat_resursov, 'nagruzka_svyazi_po_vremeni') ...
        || isempty(rezultat_resursov.nagruzka_svyazi_po_vremeni)
    znachenie = 0;
else
    znachenie = mean(rezultat_resursov.nagruzka_svyazi_po_vremeni, 'all');
end
end

function znachenie = maksimalnoe_znachenie_nagruzki_svyazi(rezultat_resursov)
if ~isfield(rezultat_resursov, 'nagruzka_svyazi_po_vremeni') ...
        || isempty(rezultat_resursov.nagruzka_svyazi_po_vremeni)
    znachenie = 0;
else
    znachenie = max(rezultat_resursov.nagruzka_svyazi_po_vremeni, [], 'all');
end
end

function dopustimost = poluchit_dopustimost_resursov(rezultat_resursov)
if isfield(rezultat_resursov, 'dopustimost_resursov')
    dopustimost = rezultat_resursov.dopustimost_resursov;
elseif isfield(rezultat_resursov, 'parametry_resursov')
    dopustimost = otsenit_dopustimost_resursov_opyta( ...
        rezultat_resursov, ...
        rezultat_resursov.parametry_resursov);
else
    dopustimost = [];
end
end

function proverit_pokazateli(pokazateli)
chisla = struct2array(pokazateli);
if any(~isfinite(chisla))
    error('%s', ...
        'Показатели ресурсов должны быть конечными числами.');
end

if pokazateli.dolya_bvs_s_dostatochnoi_energiey < 0 ...
        || pokazateli.dolya_bvs_s_dostatochnoi_energiey > 1
    error('%s', ...
        'Доля БВС с достаточной энергией должна быть в диапазоне от 0 до 1.');
end

if pokazateli.srednyaya_nagruzka_svyazi < 0 ...
        || pokazateli.srednyaya_nagruzka_svyazi > 1 ...
        || pokazateli.maksimalnaya_nagruzka_svyazi < 0 ...
        || pokazateli.maksimalnaya_nagruzka_svyazi > 1
    error('%s', ...
        'Показатели нагрузки связи должны быть в диапазоне от 0 до 1.');
end
end

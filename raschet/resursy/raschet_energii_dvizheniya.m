function rashod = raschet_energii_dvizheniya(rezultat_kinematiki, parametry_resursov)
if nargin < 2
    error('%s', [ ...
        'Для расчета энергии движения требуются результат кинематики ' ...
        'и параметры ресурсов.' ...
        ]);
end

parametry_resursov = proverit_parametry_resursov(parametry_resursov);
rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki);

chislo_momentov = numel(rezultat_kinematiki.vremya);
chislo_bvs = rezultat_kinematiki.chislo_bvs;
rashod_po_vremeni = zeros(chislo_momentov, chislo_bvs);

for nomer_momenta = 2:chislo_momentov
    for nomer_bvs = 1:chislo_bvs
        predydushchaya_tochka = reshape( ...
            rezultat_kinematiki.polozheniya(nomer_momenta - 1, nomer_bvs, :), ...
            1, 3);
        tekushchaya_tochka = reshape( ...
            rezultat_kinematiki.polozheniya(nomer_momenta, nomer_bvs, :), ...
            1, 3);
        put_na_shage = norm(tekushchaya_tochka - predydushchaya_tochka);
        rashod_po_vremeni(nomer_momenta, nomer_bvs) = ...
            put_na_shage * parametry_resursov.zatraty_dvizheniya_dzh_na_m;
    end
end

rashod = struct();
rashod.id_bvs = rezultat_kinematiki.id_bvs;
rashod.vremya = rezultat_kinematiki.vremya;
rashod.rashod_dvizheniya_po_vremeni_dzh = rashod_po_vremeni;
rashod.nakoplennyi_rashod_dzh = cumsum(rashod_po_vremeni, 1);
rashod.summarnyi_rashod_dzh = sum(rashod_po_vremeni, 1);
rashod.primechanie = [ ...
    'Расход энергии на движение рассчитан оценочно по уже готовой ' ...
    'траектории без изменения движения БВС.' ...
    ];
end

function rezultat_kinematiki = proverit_rezultat_kinematiki(rezultat_kinematiki)
obyazatelnye_polya = {
    'vremya'
    'id_bvs'
    'polozheniya'
    'chislo_bvs'
    };

if ~isstruct(rezultat_kinematiki)
    error('%s', ...
        'Результат кинематики должен быть передан в виде структуры.');
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

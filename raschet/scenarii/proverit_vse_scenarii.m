function svodka = proverit_vse_scenarii(koren_proekta)
spisok_putei = spisok_scenariev(koren_proekta);

identifikatory_scenariev = cell(1, numel(spisok_putei));
kolichestvo_bvs_po_scenariyam = repmat(struct( ...
    'id_scenariya', '', 'kolichestvo_bvs', 0), 1, numel(spisok_putei));
zashchitnye_ogranicheniya_proideny = true(1, numel(spisok_putei));

for nomer_scenariya = 1:numel(spisok_putei)
    put_k_scenariyu = spisok_putei{nomer_scenariya};
    scenarii = zagruzit_scenarii(put_k_scenariyu);
    rezultat = proverit_scenarii(scenarii, put_k_scenariyu);

    identifikatory_scenariev{nomer_scenariya} = rezultat.id_scenariya;
    kolichestvo_bvs_po_scenariyam(nomer_scenariya).id_scenariya = rezultat.id_scenariya;
    kolichestvo_bvs_po_scenariyam(nomer_scenariya).kolichestvo_bvs = rezultat.kolichestvo_bvs;
    zashchitnye_ogranicheniya_proideny(nomer_scenariya) = ...
        rezultat.zashchitnye_ogranicheniya_proideny;
end

if numel(unique(identifikatory_scenariev)) ~= numel(identifikatory_scenariev)
    error('%s', 'Идентификаторы сценариев должны быть уникальны.');
end

svodka = struct();
svodka.kolichestvo_scenariev = numel(spisok_putei);
svodka.identifikatory_scenariev = identifikatory_scenariev;
svodka.kolichestvo_bvs_po_scenariyam = kolichestvo_bvs_po_scenariyam;
svodka.zashchitnye_ogranicheniya_proideny = all(zashchitnye_ogranicheniya_proideny);

soobshchenie(sprintf( ...
    'Проверено базовых сценариев: %d.', ...
    svodka.kolichestvo_scenariev));
end

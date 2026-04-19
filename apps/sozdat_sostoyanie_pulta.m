function sostoyanie = sozdat_sostoyanie_pulta(koren_proekta)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Для создания состояния пульта требуется корень проекта.');
end

spisok_putei = spisok_scenariev(koren_proekta);
tekushchii_put = spisok_putei{1};
tekushchii_scenarii = zagruzit_scenarii(tekushchii_put);

sostoyanie = struct();
sostoyanie.koren_proekta = char(string(koren_proekta));
sostoyanie.spisok_scenariev = spisok_putei;
sostoyanie.tekushchii_scenarii = tekushchii_scenarii;
sostoyanie.tekushchii_put_k_scenariyu = tekushchii_put;
sostoyanie.parametry_svyazi = parametry_svyazi_po_umolchaniyu();
sostoyanie.parametry_zvenev = parametry_zvenev_po_umolchaniyu();
sostoyanie.parametry_peredachi = parametry_peredachi_po_umolchaniyu();
sostoyanie.demonstraciya = struct([]);
sostoyanie.dannye_vizualizacii = struct([]);
sostoyanie.tekushchii_kadr = 1;
sostoyanie.rezultat_poslednego_zapuska = struct([]);
sostoyanie.zhurnal_soobshchenii = { ...
    'Пульт исследователя инициализирован.' ...
    };
end

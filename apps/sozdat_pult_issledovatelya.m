function pult = sozdat_pult_issledovatelya(koren_proekta, vidimaya_figura)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', 'Для создания пульта требуется корень проекта.');
end

if nargin < 2
    vidimaya_figura = true;
end

if ~islogical(vidimaya_figura) || ~isscalar(vidimaya_figura)
    error('%s', ...
        'Признак видимости пульта должен быть логическим скалярным значением.');
end

sostoyanie = sozdat_sostoyanie_pulta(koren_proekta);
rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura);

okno = uifigure( ...
    'Name', 'Пульт исследователя роя БВС', ...
    'Visible', rezhim_vidimosti, ...
    'Position', [50, 50, 1600, 920]);

maket = uigridlayout(okno, [1, 1]);
maket.RowHeight = {'1x'};
maket.ColumnWidth = {'1x'};
maket.Padding = [0, 0, 0, 0];

gruppa_vkladok = uitabgroup(maket);
gruppa_vkladok.Layout.Row = 1;
gruppa_vkladok.Layout.Column = 1;

vkladki = struct();
vkladki.scenarii = uitab(gruppa_vkladok, 'Title', 'Сценарий');
vkladki.svyaz = uitab(gruppa_vkladok, 'Title', 'Связь');
vkladki.zvenya = uitab(gruppa_vkladok, 'Title', 'Звенья');
vkladki.peredacha = uitab(gruppa_vkladok, 'Title', 'Передача');
vkladki.zapusk = uitab(gruppa_vkladok, 'Title', 'Запуск');
vkladki.vosproizvedenie = uitab(gruppa_vkladok, 'Title', 'Воспроизведение');
vkladki.pokazateli = uitab(gruppa_vkladok, 'Title', 'Показатели');
vkladki.zhurnal = uitab(gruppa_vkladok, 'Title', 'Журнал');

elementy = struct();
elementy.scenariya = zapolnit_vkladku_scenariya(vkladki.scenarii, sostoyanie);
elementy.svyaz = zapolnit_vkladku_svyazi( ...
    vkladki.svyaz, ...
    sostoyanie.parametry_svyazi);
elementy.zvenya = zapolnit_vkladku_zvenev( ...
    vkladki.zvenya, ...
    sostoyanie.parametry_zvenev);
elementy.peredacha = zapolnit_vkladku_peredachi( ...
    vkladki.peredacha, ...
    sostoyanie.parametry_peredachi);
elementy.zapusk = zapolnit_vkladku_zapuska(vkladki.zapusk);
elementy.vosproizvedeniya = zapolnit_vkladku_vosproizvedeniya( ...
    vkladki.vosproizvedenie);
elementy.pokazatelei = zapolnit_vkladku_pokazatelei(vkladki.pokazateli);
elementy.zhurnala = zapolnit_vkladku_zhurnala(vkladki.zhurnal);

pult = struct();
pult.okno = okno;
pult.maket = maket;
pult.gruppa_vkladok = gruppa_vkladok;
pult.vkladki = vkladki;
pult.elementy = elementy;
pult.sostoyanie = sostoyanie;

obnovit_otobrazhenie_scenariya(pult, sostoyanie.tekushchii_scenarii);
obnovit_oblast_zhurnala(pult, sostoyanie.zhurnal_soobshchenii);

setappdata(okno, 'pult_struct', pult);
setappdata(okno, 'pult_sostoyanie', sostoyanie);

elementy.scenariya.spisok_scenariev.ValueChangedFcn = @obrabotat_vybor_scenariya;
elementy.scenariya.knopka_zagruzki.ButtonPushedFcn = @obrabotat_zagruzku_scenariya;
elementy.svyaz.knopka_po_umolchaniyu.ButtonPushedFcn = @obrabotat_svyaz_po_umolchaniyu;
elementy.zvenya.knopka_po_umolchaniyu.ButtonPushedFcn = @obrabotat_zvenya_po_umolchaniyu;
elementy.peredacha.knopka_po_umolchaniyu.ButtonPushedFcn = @obrabotat_peredachu_po_umolchaniyu;
elementy.zapusk.knopka_zapuska.ButtonPushedFcn = @obrabotat_zapusk_rascheta;
elementy.zapusk.knopka_otkryt_demonstraciyu.ButtonPushedFcn = @obrabotat_otkryt_demonstraciyu;
elementy.zapusk.knopka_sohranit_otchet.ButtonPushedFcn = @obrabotat_sohranit_otchet;
elementy.vosproizvedeniya.polzunok_kadra.ValueChangedFcn = @obrabotat_polzunok_kadra;
elementy.vosproizvedeniya.knopka_pervyi.ButtonPushedFcn = @obrabotat_pervyi_kadr;
elementy.vosproizvedeniya.knopka_nazad.ButtonPushedFcn = @obrabotat_predydushchii_kadr;
elementy.vosproizvedeniya.knopka_vpered.ButtonPushedFcn = @obrabotat_sleduyushchii_kadr;
elementy.vosproizvedeniya.knopka_poslednii.ButtonPushedFcn = @obrabotat_poslednii_kadr;
elementy.vosproizvedeniya.knopka_obnovit.ButtonPushedFcn = @obrabotat_obnovlenie_sceny;
elementy.pokazatelei.knopka_obnovit_grafiki.ButtonPushedFcn = @obrabotat_obnovlenie_grafikov;
elementy.pokazatelei.knopka_sohranit_grafiki.ButtonPushedFcn = @obrabotat_sohranenie_grafikov;
elementy.zhurnala.knopka_ochistit.ButtonPushedFcn = @obrabotat_ochistku_zhurnala;

    function obrabotat_vybor_scenariya(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        [sost, scenarii] = zagruzit_vybrannyi_scenarii(tekushchii_pult, sost);
        sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
            sost.zhurnal_soobshchenii, ...
            ['Выбран сценарий `' scenarii.id_scenariya '`.']);
        tekushchii_pult.sostoyanie = sost;
        obnovit_otobrazhenie_scenariya(tekushchii_pult, scenarii);
        obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_zagruzku_scenariya(~, ~)
        obrabotat_vybor_scenariya();
    end

    function obrabotat_svyaz_po_umolchaniyu(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        zapolnit_parametry_svyazi_v_interfeis( ...
            tekushchii_pult, ...
            parametry_svyazi_po_umolchaniyu());
    end

    function obrabotat_zvenya_po_umolchaniyu(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        zapolnit_parametry_zvenev_v_interfeis( ...
            tekushchii_pult, ...
            parametry_zvenev_po_umolchaniyu());
    end

    function obrabotat_peredachu_po_umolchaniyu(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        zapolnit_parametry_peredachi_v_interfeis( ...
            tekushchii_pult, ...
            parametry_peredachi_po_umolchaniyu());
    end

    function obrabotat_zapusk_rascheta(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        ustanovit_sostoyanie_zapuska( ...
            tekushchii_pult, ...
            'Состояние: выполняется расчет...');
        drawnow

        try
            [sost, ~, ~] = vypolnit_raschet_iz_pulta(tekushchii_pult);
            tekushchii_pult.sostoyanie = sost;
            tekushchii_pult = obnovit_pult_posle_rascheta(tekushchii_pult);
            ustanovit_sostoyanie_zapuska( ...
                tekushchii_pult, ...
                'Состояние: расчет завершен успешно.');
            sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
                sost.zhurnal_soobshchenii, ...
                'Расчет из пульта завершен успешно.');
            tekushchii_pult.sostoyanie = sost;
            obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
            sohranit_pult_v_okne(tekushchii_pult);
        catch oshibka
            ustanovit_sostoyanie_zapuska( ...
                tekushchii_pult, ...
                'Состояние: расчет завершен с ошибкой.', ...
                [0.80, 0.18, 0.18]);
            sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
            sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
                sost.zhurnal_soobshchenii, ...
                ['Ошибка расчета: ' oshibka.message]);
            tekushchii_pult.sostoyanie = sost;
            obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
            sohranit_pult_v_okne(tekushchii_pult);
            uialert(okno, oshibka.message, 'Ошибка расчета');
        end
    end

    function obrabotat_otkryt_demonstraciyu(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        if isempty(sost.dannye_vizualizacii)
            uialert(okno, ...
                'Сначала выполните расчет из пульта.', ...
                'Нет данных демонстрации');
            return
        end

        postroit_scenu_roya_3d(sost.dannye_vizualizacii, true);
        postroit_grafiki_pokazatelei(sost.dannye_vizualizacii, true);
        sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
            sost.zhurnal_soobshchenii, ...
            'Открыты отдельные окна демонстрации.');
        tekushchii_pult.sostoyanie = sost;
        obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_sohranit_otchet(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        if isempty(sost.demonstraciya) || isempty(sost.dannye_vizualizacii)
            uialert(okno, ...
                'Сначала выполните расчет из пульта.', ...
                'Нет данных для отчета');
            return
        end

        papka_otcheta = sohranit_otchet_demonstracii( ...
            sost.demonstraciya, ...
            sost.dannye_vizualizacii, ...
            sost.koren_proekta);
        sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
            sost.zhurnal_soobshchenii, ...
            ['Сохранен отчет демонстрации: ' papka_otcheta]);
        tekushchii_pult.sostoyanie = sost;
        obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_polzunok_kadra(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        sost.tekushchii_kadr = round( ...
            tekushchii_pult.elementy.vosproizvedeniya.polzunok_kadra.Value);
        tekushchii_pult.sostoyanie = sost;
        tekushchii_pult = obnovit_pult_posle_rascheta(tekushchii_pult);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_pervyi_kadr(~, ~)
        pereyti_k_kadru(1);
    end

    function obrabotat_predydushchii_kadr(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        pereyti_k_kadru(max(1, sost.tekushchii_kadr - 1));
    end

    function obrabotat_sleduyushchii_kadr(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        chislo_kadrov = poluchit_chislo_kadrov(sost);
        pereyti_k_kadru(min(chislo_kadrov, sost.tekushchii_kadr + 1));
    end

    function obrabotat_poslednii_kadr(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        pereyti_k_kadru(poluchit_chislo_kadrov(sost));
    end

    function obrabotat_obnovlenie_sceny(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        tekushchii_pult = obnovit_pult_posle_rascheta(tekushchii_pult);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_obnovlenie_grafikov(~, ~)
        obrabotat_obnovlenie_sceny();
    end

    function obrabotat_sohranenie_grafikov(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        if isempty(sost.dannye_vizualizacii)
            uialert(okno, ...
                'Сначала выполните расчет из пульта.', ...
                'Нет данных для графиков');
            return
        end

        papka_rezultatov = fullfile(sost.koren_proekta, 'opyty', 'rezultaty');
        if ~isfolder(papka_rezultatov)
            mkdir(papka_rezultatov);
        end

        metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
        put_k_failu = fullfile(papka_rezultatov, ...
            ['grafiki_pulta_' char(string(sost.dannye_vizualizacii.id_scenariya)) '_' metka_vremeni '.png']);
        grafiki = postroit_grafiki_pokazatelei(sost.dannye_vizualizacii, false);
        ochistka = onCleanup(@() close(grafiki.figura));
        exportgraphics(grafiki.figura, put_k_failu);
        clear ochistka
        close(grafiki.figura);

        sost.zhurnal_soobshchenii = dobavit_zapis_v_zhurnal_pulta( ...
            sost.zhurnal_soobshchenii, ...
            ['Сохранены графики показателей: ' put_k_failu]);
        tekushchii_pult.sostoyanie = sost;
        obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function obrabotat_ochistku_zhurnala(~, ~)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        sost.zhurnal_soobshchenii = {'Журнал пульта очищен.'};
        tekushchii_pult.sostoyanie = sost;
        obnovit_oblast_zhurnala(tekushchii_pult, sost.zhurnal_soobshchenii);
        sohranit_pult_v_okne(tekushchii_pult);
    end

    function pereyti_k_kadru(nomer_kadra)
        tekushchii_pult = poluchit_pult_iz_okna(okno);
        sost = poluchit_sostoyanie_iz_okna(tekushchii_pult);
        sost.tekushchii_kadr = nomer_kadra;
        tekushchii_pult.sostoyanie = sost;
        tekushchii_pult = obnovit_pult_posle_rascheta(tekushchii_pult);
        sohranit_pult_v_okne(tekushchii_pult);
    end
end

function rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura)
if vidimaya_figura
    rezhim_vidimosti = 'on';
else
    rezhim_vidimosti = 'off';
end
end

function pult = poluchit_pult_iz_okna(okno)
pult = getappdata(okno, 'pult_struct');
if isempty(pult)
    error('%s', 'В окне пульта отсутствует сохраненная структура пульта.');
end
end

function sostoyanie = poluchit_sostoyanie_iz_okna(pult)
sostoyanie = getappdata(pult.okno, 'pult_sostoyanie');
if isempty(sostoyanie)
    sostoyanie = pult.sostoyanie;
end
end

function sohranit_pult_v_okne(pult)
setappdata(pult.okno, 'pult_struct', pult);
setappdata(pult.okno, 'pult_sostoyanie', pult.sostoyanie);
end

function [sostoyanie, scenarii] = zagruzit_vybrannyi_scenarii(pult, sostoyanie)
vybrannyi_id = char(string(pult.elementy.scenariya.spisok_scenariev.Value));
put_k_scenariyu = nayti_put_k_scenariyu( ...
    sostoyanie.spisok_scenariev, ...
    vybrannyi_id);
scenarii = zagruzit_scenarii(put_k_scenariyu);
sostoyanie.tekushchii_put_k_scenariyu = put_k_scenariyu;
sostoyanie.tekushchii_scenarii = scenarii;
end

function put_k_scenariyu = nayti_put_k_scenariyu(spisok_putei, identifikator)
put_k_scenariyu = '';
for nomer_puti = 1:numel(spisok_putei)
    [~, imya_scenariya] = fileparts(spisok_putei{nomer_puti});
    if strcmp(imya_scenariya, identifikator)
        put_k_scenariyu = spisok_putei{nomer_puti};
        return
    end
end

error('%s', sprintf( ...
    'Не найден сценарий `%s` в списке доступных сценариев.', ...
    identifikator));
end

function ustanovit_sostoyanie_zapuska(pult, tekst, cvet)
if nargin < 3
    cvet = [0.10, 0.10, 0.10];
end

pult.elementy.zapusk.indikator_sostoyaniya.Text = tekst;
pult.elementy.zapusk.indikator_sostoyaniya.FontColor = cvet;
end

function chislo_kadrov = poluchit_chislo_kadrov(sostoyanie)
if isempty(sostoyanie.dannye_vizualizacii)
    chislo_kadrov = 1;
else
    chislo_kadrov = numel(sostoyanie.dannye_vizualizacii.kadry);
end
end

function obnovit_otobrazhenie_scenariya(pult, scenarii)
pult.elementy.scenariya.oblast_opisaniya.Value = { ...
    ['Идентификатор: ' char(string(scenarii.id_scenariya))]
    ['Название: ' char(string(scenarii.nazvanie))]
    ['Описание: ' char(string(scenarii.opisanie))]
    ['Время моделирования, с: ' num2str(double(scenarii.vremya_modelirovaniya))]
    ['Шаг моделирования, с: ' num2str(double(scenarii.shag_modelirovaniya))]
    };

pult.elementy.scenariya.tablica_sostava.Data = sobrat_tablicu_sostava_roya(scenarii);
pult.elementy.scenariya.tablica_tselei.Data = sobrat_tablicu_tselei(scenarii);
pult.elementy.scenariya.tablica_ogranichenii.Data = ...
    sobrat_tablicu_ogranichenii(scenarii);
end

function obnovit_oblast_zhurnala(pult, zhurnal_soobshchenii)
if isempty(zhurnal_soobshchenii)
    pult.elementy.zhurnala.oblast_zhurnala.Value = {'Журнал пульта пуст.'};
else
    pult.elementy.zhurnala.oblast_zhurnala.Value = zhurnal_soobshchenii(:);
end
end

function zapolnit_parametry_svyazi_v_interfeis(pult, parametry_svyazi)
pult.elementy.svyaz.maksimalnaya_dalnost.Value = ...
    parametry_svyazi.maksimalnaya_dalnost_m;
pult.elementy.svyaz.porog_signal_shum.Value = ...
    parametry_svyazi.porog_otnosheniya_signal_shum;
pult.elementy.svyaz.moshchnost_peredatchika.Value = ...
    parametry_svyazi.moshchnost_peredatchika_vt;
pult.elementy.svyaz.moshchnost_shuma.Value = ...
    parametry_svyazi.moshchnost_shuma_vt;
pult.elementy.svyaz.polosa_chastot.Value = ...
    parametry_svyazi.polosa_chastot_gts;
pult.elementy.svyaz.razmer_soobshcheniya.Value = ...
    parametry_svyazi.razmer_soobshcheniya_bit;
pult.elementy.svyaz.ves_propusknoi_sposobnosti.Value = ...
    parametry_svyazi.ves_propusknoi_sposobnosti;
pult.elementy.svyaz.ves_dlitelnosti_svyazi.Value = ...
    parametry_svyazi.ves_dlitelnosti_svyazi;
pult.elementy.svyaz.ves_energeticheskoi_stoimosti.Value = ...
    parametry_svyazi.ves_energeticheskoi_stoimosti;
end

function zapolnit_parametry_zvenev_v_interfeis(pult, parametry_zvenev)
pult.elementy.zvenya.minimalnyi_razmer_zvena.Value = ...
    parametry_zvenev.minimalnyi_razmer_zvena;
pult.elementy.zvenya.maksimalnyi_razmer_zvena.Value = ...
    parametry_zvenev.maksimalnyi_razmer_zvena;
pult.elementy.zvenya.ves_stepeni_bvs.Value = ...
    parametry_zvenev.ves_stepeni_bvs;
pult.elementy.zvenya.ves_poleznosti_linii.Value = ...
    parametry_zvenev.ves_poleznosti_linii;
pult.elementy.zvenya.ves_centralnosti.Value = ...
    parametry_zvenev.ves_centralnosti;
pult.elementy.zvenya.ves_zapasa_energii.Value = ...
    parametry_zvenev.ves_zapasa_energii;
pult.elementy.zvenya.razreshit_odinochnye_zvenya.Value = ...
    logical(parametry_zvenev.razreshit_odinochnye_zvenya);
end

function zapolnit_parametry_peredachi_v_interfeis(pult, parametry_peredachi)
pult.elementy.peredacha.maksimalnyi_razmer_ocheredi.Value = ...
    parametry_peredachi.maksimalnyi_razmer_ocheredi;
pult.elementy.peredacha.maksimalnoe_chislo_peresylok.Value = ...
    parametry_peredachi.maksimalnoe_chislo_peresylok;
pult.elementy.peredacha.vremya_zhizni_soobshcheniya.Value = ...
    parametry_peredachi.vremya_zhizni_soobshcheniya_s;
pult.elementy.peredacha.bazovyi_razmer_soobshcheniya.Value = ...
    parametry_peredachi.bazovyi_razmer_soobshcheniya_bit;
pult.elementy.peredacha.propuskat_cherez_golovnye_bvs.Value = ...
    logical(parametry_peredachi.propuskat_cherez_golovnye_bvs);
pult.elementy.peredacha.razreshit_pryamuyu_peredachu.Value = ...
    logical(parametry_peredachi.razreshit_pryamuyu_peredachu);
pult.elementy.peredacha.ves_zaderzhki.Value = parametry_peredachi.ves_zaderzhki;
pult.elementy.peredacha.ves_chisla_peresylok.Value = ...
    parametry_peredachi.ves_chisla_peresylok;
pult.elementy.peredacha.ves_dostavki.Value = parametry_peredachi.ves_dostavki;
end

function tablica = sobrat_tablicu_sostava_roya(scenarii)
chislo_bvs = numel(scenarii.sostav_roya);
tablica = cell(chislo_bvs, 3);
for nomer_bvs = 1:chislo_bvs
    tekushchii_bvs = scenarii.sostav_roya(nomer_bvs);
    tablica{nomer_bvs, 1} = char(string(tekushchii_bvs.id_bvs));
    tablica{nomer_bvs, 2} = char(string(tekushchii_bvs.rol));
    tablica{nomer_bvs, 3} = double(tekushchii_bvs.zapas_energii);
end
end

function tablica = sobrat_tablicu_tselei(scenarii)
if isempty(scenarii.tseli_zadaniya)
    tablica = {'Нет целей задания', '', ''};
    return
end

chislo_tselei = numel(scenarii.tseli_zadaniya);
tablica = cell(chislo_tselei, 3);
for nomer_tseli = 1:chislo_tselei
    tekushchaya_tsel = scenarii.tseli_zadaniya(nomer_tseli);
    tablica{nomer_tseli, 1} = poluchit_pole_ili_pustuyu_stroku( ...
        tekushchaya_tsel, 'id_tseli');
    tablica{nomer_tseli, 2} = poluchit_pole_ili_pustuyu_stroku( ...
        tekushchaya_tsel, 'tip');
    tablica{nomer_tseli, 3} = poluchit_pole_ili_pustuyu_stroku( ...
        tekushchaya_tsel, 'opisanie');
end
end

function tablica = sobrat_tablicu_ogranichenii(scenarii)
polya = fieldnames(scenarii.ogranicheniya_bezopasnosti);
tablica = cell(numel(polya), 2);
for nomer_polya = 1:numel(polya)
    imya_polya = polya{nomer_polya};
    tablica{nomer_polya, 1} = imya_polya;
    tablica{nomer_polya, 2} = scenarii.ogranicheniya_bezopasnosti.(imya_polya);
end
end

function znachenie = poluchit_pole_ili_pustuyu_stroku(struktura, imya_polya)
if isfield(struktura, imya_polya)
    znachenie = char(string(struktura.(imya_polya)));
else
    znachenie = '';
end
end

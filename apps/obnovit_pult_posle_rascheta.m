function pult = obnovit_pult_posle_rascheta(pult)
if nargin < 1 || ~isstruct(pult) || ~isfield(pult, 'elementy')
    error('%s', 'Для обновления пульта требуется структура пульта.');
end

if ~isfield(pult, 'sostoyanie') || ~isstruct(pult.sostoyanie)
    error('%s', 'В структуре пульта отсутствует состояние.');
end

sostoyanie = pult.sostoyanie;
obnovit_oblast_zhurnala(pult, sostoyanie.zhurnal_soobshchenii);
obnovit_tablicu_itogov(pult, sostoyanie);

if isempty(sostoyanie.dannye_vizualizacii)
    return
end

chislo_kadrov = numel(sostoyanie.dannye_vizualizacii.kadry);
sostoyanie.tekushchii_kadr = min(max(1, round(sostoyanie.tekushchii_kadr)), chislo_kadrov);
pult.sostoyanie = sostoyanie;

polzunok = pult.elementy.vosproizvedeniya.polzunok_kadra;
polzunok.Limits = [1, max(chislo_kadrov, 2)];
polzunok.MajorTicks = unique(round(linspace(1, chislo_kadrov, min(chislo_kadrov, 5))));
polzunok.Value = sostoyanie.tekushchii_kadr;

pult.elementy.vosproizvedeniya.pole_nomer_kadra.Value = sostoyanie.tekushchii_kadr;
pult.elementy.vosproizvedeniya.pole_tekushego_vremeni.Value = sprintf( ...
    't = %.2f с', ...
    sostoyanie.dannye_vizualizacii.vremya(sostoyanie.tekushchii_kadr));

obnovit_scenu_na_uiaxes( ...
    pult.elementy.vosproizvedeniya.osi, ...
    sostoyanie.dannye_vizualizacii, ...
    sostoyanie.tekushchii_kadr);
obnovit_grafiki_pokazatelei_v_pulte( ...
    pult.elementy.pokazatelei.osi, ...
    sostoyanie.dannye_vizualizacii);
obnovit_tablicu_pokazatelei(pult, sostoyanie);
end

function obnovit_oblast_zhurnala(pult, zhurnal_soobshchenii)
if isempty(zhurnal_soobshchenii)
    pult.elementy.zhurnala.oblast_zhurnala.Value = {'Журнал пульта пуст.'};
else
    pult.elementy.zhurnala.oblast_zhurnala.Value = zhurnal_soobshchenii(:);
end
end

function obnovit_tablicu_itogov(pult, sostoyanie)
tablica = {'Пока нет результатов', ''};
if ~isempty(sostoyanie.rezultat_poslednego_zapuska)
    rezultat = sostoyanie.rezultat_poslednego_zapuska;
    tablica = {
        'Идентификатор сценария', rezultat.id_scenariya
        'Число БВС', rezultat.chislo_bvs
        'Длительность опыта, с', rezultat.vremya_modelirovaniya
        'Шаг моделирования, с', rezultat.shag_modelirovaniya
        'Доля времени связного роя', rezultat.dolya_vremeni_svyaznogo_roya
        'Среднее число звеньев', rezultat.srednee_chislo_zvenev
        'Доля доставленных сообщений', rezultat.dolya_dostavlennyh
        'Средняя задержка доставки, с', rezultat.srednyaya_zaderzhka_dostavki_s
        };
end

pult.elementy.zapusk.tablica_itogov.Data = tablica;
end

function obnovit_tablicu_pokazatelei(pult, sostoyanie)
pokazateli = sostoyanie.dannye_vizualizacii.pokazateli;
peredacha = sostoyanie.demonstraciya.peredacha;
tablica = {
    'Число БВС', pokazateli.chislo_bvs
    'Доля времени связного роя', pokazateli.dolya_vremeni_svyaznogo_roya
    'Среднее число звеньев', pokazateli.srednee_chislo_zvenev
    'Доля доставленных сообщений', pokazateli.dolya_dostavlennyh
    'Число сообщений', peredacha.chislo_soobshchenii
    'Число доставленных', peredacha.chislo_dostavlennyh
    'Число потерянных', peredacha.chislo_poteryannyh
    'Средняя задержка доставки, с', peredacha.srednyaya_zaderzhka_dostavki_s
    'Среднее число пересылок', peredacha.srednee_chislo_peresylok
    };

pult.elementy.pokazatelei.tablica_pokazatelei.Data = tablica;
end

function obnovit_scenu_na_uiaxes(osi, dannye_vizualizacii, nomer_kadra)
granicy = proverit_oblast_poleta(dannye_vizualizacii.granicy_oblasti);
kadr = dannye_vizualizacii.kadry(nomer_kadra);
id_bvs = dannye_vizualizacii.id_bvs;

cla(osi);
hold(osi, 'on');
grid(osi, 'on');
box(osi, 'on');
view(osi, 3);
axis(osi, 'equal');
xlim(osi, [granicy.xmin, granicy.xmax]);
ylim(osi, [granicy.ymin, granicy.ymax]);
zlim(osi, [granicy.zmin, granicy.zmax]);
xlabel(osi, 'X, м');
ylabel(osi, 'Y, м');
zlabel(osi, 'Z, м');

narisovat_granicy_oblasti(osi, granicy);
narisovat_obekty_sredy(osi, dannye_vizualizacii.prepyatstviya, [0.80, 0.25, 0.25], 0.10);
narisovat_obekty_sredy(osi, dannye_vizualizacii.zony_zapreta, [0.85, 0.55, 0.10], 0.08);
narisovat_tseli(osi, dannye_vizualizacii.tseli_zadaniya);
narisovat_traektorii(osi, dannye_vizualizacii, id_bvs);

cveta_bvs = poluchit_cveta_bvs(kadr, numel(id_bvs));
scatter3( ...
    osi, ...
    kadr.polozheniya_bvs(:, 1), ...
    kadr.polozheniya_bvs(:, 2), ...
    kadr.polozheniya_bvs(:, 3), ...
    55, ...
    cveta_bvs, ...
    'filled', ...
    'MarkerEdgeColor', [0.1, 0.1, 0.1]);

for nomer_bvs = 1:numel(id_bvs)
    polozhenie = kadr.polozheniya_bvs(nomer_bvs, :);
    text(osi, polozhenie(1), polozhenie(2), polozhenie(3), ...
        [' ' id_bvs{nomer_bvs}], 'FontSize', 8);
end

narisovat_linii_svyazi(osi, kadr);
narisovat_golovnye_bvs(osi, kadr, id_bvs);
title(osi, sprintf('Кадр %d, t = %.2f с', nomer_kadra, kadr.vremya));
hold(osi, 'off');
end

function obnovit_grafiki_pokazatelei_v_pulte(osi, dannye_vizualizacii)
vremya = dannye_vizualizacii.vremya(:).';
pokazateli = dannye_vizualizacii.pokazateli;

dannye_grafikov = {
    pokazateli.chislo_linii_po_vremeni, 'Число линий связи', 'Линии'
    pokazateli.srednyaya_stepen_po_vremeni, 'Средняя степень БВС', 'Степень'
    pokazateli.chislo_zvenev_po_vremeni, 'Число звеньев', 'Звенья'
    pokazateli.chislo_odinochnyh_zvenev_po_vremeni, 'Число одиночных звеньев', 'Одиночные звенья'
    pokazateli.dolya_dostavlennyh_po_vremeni, 'Доля доставленных сообщений', 'Доля'
    pokazateli.nakoplennoe_chislo_dostavlennyh, 'Накопленное число доставленных', 'Сообщения'
    pokazateli.nakoplennoe_chislo_poteryannyh, 'Накопленное число потерянных', 'Сообщения'
    pokazateli.srednyaya_zaderzhka_dostavki_po_vremeni, 'Средняя задержка доставки', 'Секунды'
    pokazateli.srednee_chislo_peresylok_po_vremeni, 'Среднее число пересылок', 'Пересылки'
    };

for nomer_osi = 1:numel(osi)
    cla(osi(nomer_osi));
    plot(osi(nomer_osi), vremya, dannye_grafikov{nomer_osi, 1}, 'LineWidth', 1.2);
    title(osi(nomer_osi), dannye_grafikov{nomer_osi, 2});
    xlabel(osi(nomer_osi), 'Время, с');
    ylabel(osi(nomer_osi), dannye_grafikov{nomer_osi, 3});
    grid(osi(nomer_osi), 'on');

    if nomer_osi == 5
        ylim(osi(nomer_osi), [0, 1]);
    end
end
end

function narisovat_granicy_oblasti(osi, granicy)
[x, y, z] = poluchit_rebra_parallelepipeda(granicy);
plot3(osi, x.', y.', z.', ...
    'Color', [0.35, 0.35, 0.35], ...
    'LineStyle', '--', ...
    'LineWidth', 1.0);
end

function narisovat_obekty_sredy(osi, obekty_sredy, cvet, prozrachnost)
if isempty(obekty_sredy)
    return
end

for nomer_obekta = 1:numel(obekty_sredy)
    granitsy = proverit_granicy_obekta(obekty_sredy(nomer_obekta));
    patch(osi, ...
        'Vertices', poluchit_vershiny_parallelepipeda(granitsy), ...
        'Faces', poluchit_grani_parallelepipeda(), ...
        'FaceColor', cvet, ...
        'FaceAlpha', prozrachnost, ...
        'EdgeColor', cvet, ...
        'LineWidth', 1.0);
end
end

function narisovat_tseli(osi, tseli_zadaniya)
if isempty(tseli_zadaniya)
    return
end

for nomer_tseli = 1:numel(tseli_zadaniya)
    tsel = tseli_zadaniya(nomer_tseli);
    if isfield(tsel, 'granitsy')
        granitsy = proverit_oblast_poleta(tsel.granitsy);
        centr = [ ...
            (granitsy.xmin + granitsy.xmax) / 2, ...
            (granitsy.ymin + granitsy.ymax) / 2, ...
            (granitsy.zmin + granitsy.zmax) / 2];
    elseif isfield(tsel, 'tochka')
        centr = reshape(double(tsel.tochka), 1, 3);
    else
        centr = [0, 0, 0];
    end

    plot3(osi, centr(1), centr(2), centr(3), 'p', ...
        'MarkerSize', 10, ...
        'MarkerFaceColor', [0.15, 0.55, 0.15], ...
        'MarkerEdgeColor', [0.1, 0.3, 0.1]);
end
end

function narisovat_traektorii(osi, dannye_vizualizacii, id_bvs)
chislo_kadrov = numel(dannye_vizualizacii.kadry);
for nomer_bvs = 1:numel(id_bvs)
    x = zeros(1, chislo_kadrov);
    y = zeros(1, chislo_kadrov);
    z = zeros(1, chislo_kadrov);
    for nomer_kadra = 1:chislo_kadrov
        polozhenie = dannye_vizualizacii.kadry(nomer_kadra).polozheniya_bvs( ...
            nomer_bvs, :);
        x(nomer_kadra) = polozhenie(1);
        y(nomer_kadra) = polozhenie(2);
        z(nomer_kadra) = polozhenie(3);
    end
    plot3(osi, x, y, z, 'Color', [0.55, 0.55, 0.55], 'LineWidth', 0.8);
end
end

function narisovat_linii_svyazi(osi, kadr)
[stroki, stolbcy] = find(triu(logical(kadr.matrica_smeznosti), 1));
for nomer_linii = 1:numel(stroki)
    pervaya_tochka = kadr.polozheniya_bvs(stroki(nomer_linii), :);
    vtoraya_tochka = kadr.polozheniya_bvs(stolbcy(nomer_linii), :);
    plot3(osi, ...
        [pervaya_tochka(1), vtoraya_tochka(1)], ...
        [pervaya_tochka(2), vtoraya_tochka(2)], ...
        [pervaya_tochka(3), vtoraya_tochka(3)], ...
        'Color', [0.20, 0.55, 0.90], ...
        'LineWidth', 1.1);
end
end

function narisovat_golovnye_bvs(osi, kadr, id_bvs)
indeksy = [];
for nomer_golovnogo = 1:numel(kadr.golovnye_bvs)
    indeks = find(strcmp(id_bvs, char(string(kadr.golovnye_bvs{nomer_golovnogo}))), 1);
    if ~isempty(indeks)
        indeksy(end + 1) = indeks; %#ok<AGROW>
    end
end

if isempty(indeksy)
    return
end

scatter3(osi, ...
    kadr.polozheniya_bvs(indeksy, 1), ...
    kadr.polozheniya_bvs(indeksy, 2), ...
    kadr.polozheniya_bvs(indeksy, 3), ...
    140, ...
    'd', ...
    'MarkerFaceColor', [0.95, 0.85, 0.10], ...
    'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
    'LineWidth', 1.2);
end

function cveta_bvs = poluchit_cveta_bvs(kadr, chislo_bvs)
cveta_bvs = repmat([0.00, 0.45, 0.74], chislo_bvs, 1);
chislo_zvenev = numel(kadr.zvenya);
palitra = lines(max(chislo_zvenev, 1));

for nomer_zvena = 1:chislo_zvenev
    indeksy = kadr.zvenya(nomer_zvena).indeksy_bvs;
    cveta_bvs(indeksy, :) = repmat(palitra(nomer_zvena, :), numel(indeksy), 1);
end
end

function granitsy = proverit_granicy_obekta(obekt)
if ~isstruct(obekt) || ~isfield(obekt, 'granitsy')
    error('%s', 'Объект среды должен содержать поле granitsy.');
end

granitsy = proverit_oblast_poleta(obekt.granitsy, 'границ объекта среды');
end

function [x, y, z] = poluchit_rebra_parallelepipeda(granicy)
vershiny = poluchit_vershiny_parallelepipeda(granicy);
rebra = [ ...
    1 2
    2 3
    3 4
    4 1
    5 6
    6 7
    7 8
    8 5
    1 5
    2 6
    3 7
    4 8
    ];

x = nan(size(rebra, 1), 2);
y = nan(size(rebra, 1), 2);
z = nan(size(rebra, 1), 2);
for nomer_rebra = 1:size(rebra, 1)
    x(nomer_rebra, :) = vershiny(rebra(nomer_rebra, :), 1);
    y(nomer_rebra, :) = vershiny(rebra(nomer_rebra, :), 2);
    z(nomer_rebra, :) = vershiny(rebra(nomer_rebra, :), 3);
end
end

function vershiny = poluchit_vershiny_parallelepipeda(granicy)
vershiny = [ ...
    granicy.xmin, granicy.ymin, granicy.zmin
    granicy.xmax, granicy.ymin, granicy.zmin
    granicy.xmax, granicy.ymax, granicy.zmin
    granicy.xmin, granicy.ymax, granicy.zmin
    granicy.xmin, granicy.ymin, granicy.zmax
    granicy.xmax, granicy.ymin, granicy.zmax
    granicy.xmax, granicy.ymax, granicy.zmax
    granicy.xmin, granicy.ymax, granicy.zmax
    ];
end

function grani = poluchit_grani_parallelepipeda()
grani = [ ...
    1 2 3 4
    5 6 7 8
    1 2 6 5
    2 3 7 6
    3 4 8 7
    4 1 5 8
    ];
end

function grafika = postroit_scenu_roya_3d(dannye_vizualizacii, vidimaya_figura)
if nargin < 1 || ~isstruct(dannye_vizualizacii)
    error('%s', 'Для построения сцены требуется структура данных визуализации.');
end

if nargin < 2
    vidimaya_figura = true;
end

if ~isfield(dannye_vizualizacii, 'kadry') || isempty(dannye_vizualizacii.kadry)
    error('%s', 'В данных визуализации отсутствуют кадры.');
end

granicy = proverit_oblast_poleta(dannye_vizualizacii.granicy_oblasti);
pervyi_kadr = dannye_vizualizacii.kadry(1);
chislo_bvs = numel(dannye_vizualizacii.id_bvs);
cveta_bvs = poluchit_cveta_bvs(pervyi_kadr, chislo_bvs);

rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura);
figura = figure( ...
    'Name', 'Сцена роя БВС', ...
    'NumberTitle', 'off', ...
    'Visible', rezhim_vidimosti, ...
    'Color', 'w');
osi = axes('Parent', figura);
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

granicy_oblasti = narisovat_granicy_oblasti(osi, granicy);
prepyatstviya = narisovat_obekty_sredy( ...
    osi, ...
    dannye_vizualizacii.prepyatstviya, ...
    [0.80, 0.25, 0.25], ...
    0.10);
zony_zapreta = narisovat_obekty_sredy( ...
    osi, ...
    dannye_vizualizacii.zony_zapreta, ...
    [0.85, 0.55, 0.10], ...
    0.08);
tseli = narisovat_tseli(osi, dannye_vizualizacii.tseli_zadaniya);
trajektorii = narisovat_traektorii(osi, dannye_vizualizacii);

tochki_bvs = scatter3( ...
    osi, ...
    pervyi_kadr.polozheniya_bvs(:, 1), ...
    pervyi_kadr.polozheniya_bvs(:, 2), ...
    pervyi_kadr.polozheniya_bvs(:, 3), ...
    60, ...
    cveta_bvs, ...
    'filled', ...
    'MarkerEdgeColor', [0.1, 0.1, 0.1]);

podpisi_bvs = gobjects(1, chislo_bvs);
for nomer_bvs = 1:chislo_bvs
    polozhenie = pervyi_kadr.polozheniya_bvs(nomer_bvs, :);
    podpisi_bvs(nomer_bvs) = text( ...
        osi, ...
        polozhenie(1), polozhenie(2), polozhenie(3), ...
        [' ' dannye_vizualizacii.id_bvs{nomer_bvs}], ...
        'FontSize', 8, ...
        'Color', [0.15, 0.15, 0.15]);
end

golovnye_bvs = narisovat_golovnye_bvs( ...
    osi, ...
    pervyi_kadr, ...
    dannye_vizualizacii.id_bvs);
linii_svyazi = narisovat_linii_svyazi(osi, pervyi_kadr);

podpis_vremeni = title( ...
    osi, ...
    sprintf('Сцена роя БВС, t = %.2f с', pervyi_kadr.vremya));
podpis_sobytii = text( ...
    osi, ...
    0.01, 0.99, ...
    poluchit_podpis_sobytii(pervyi_kadr.sobytiya_peredachi), ...
    'Units', 'normalized', ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 9, ...
    'BackgroundColor', [1, 1, 1], ...
    'Margin', 6);

grafika = struct();
grafika.figura = figura;
grafika.osi = osi;
grafika.granicy_oblasti = granicy_oblasti;
grafika.prepyatstviya = prepyatstviya;
grafika.zony_zapreta = zony_zapreta;
grafika.tseli = tseli;
grafika.trajektorii = trajektorii;
grafika.tochki_bvs = tochki_bvs;
grafika.podpisi_bvs = podpisi_bvs;
grafika.linii_svyazi = linii_svyazi;
grafika.golovnye_bvs = golovnye_bvs;
grafika.podpis_vremeni = podpis_vremeni;
grafika.podpis_sobytii = podpis_sobytii;
grafika.id_bvs = dannye_vizualizacii.id_bvs;
grafika.poslednii_kadr = 1;
end

function rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura)
if islogical(vidimaya_figura) && isscalar(vidimaya_figura)
    if vidimaya_figura
        rezhim_vidimosti = 'on';
    else
        rezhim_vidimosti = 'off';
    end
else
    error('%s', ...
        'Признак видимости фигуры должен быть логическим скалярным значением.');
end
end

function granicy_oblasti = narisovat_granicy_oblasti(osi, granicy)
[x, y, z] = poluchit_rebra_parallelepipeda(granicy);
granicy_oblasti = plot3( ...
    osi, x.', y.', z.', ...
    'Color', [0.35, 0.35, 0.35], ...
    'LineStyle', '--', ...
    'LineWidth', 1.0);
end

function obekty = narisovat_obekty_sredy(osi, obekty_sredy, cvet, prozrachnost)
if isempty(obekty_sredy)
    obekty = gobjects(0);
    return
end

obekty = gobjects(1, numel(obekty_sredy));
for nomer_obekta = 1:numel(obekty_sredy)
    granitsy = proverit_granicy_obekta(obekty_sredy(nomer_obekta));
    obekty(nomer_obekta) = patch( ...
        osi, ...
        'Vertices', poluchit_vershiny_parallelepipeda(granitsy), ...
        'Faces', poluchit_grani_parallelepipeda(), ...
        'FaceColor', cvet, ...
        'FaceAlpha', prozrachnost, ...
        'EdgeColor', cvet, ...
        'LineWidth', 1.0);
end
end

function tseli = narisovat_tseli(osi, tseli_zadaniya)
if isempty(tseli_zadaniya)
    tseli = gobjects(0);
    return
end

tseli = gobjects(1, numel(tseli_zadaniya));
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

    tseli(nomer_tseli) = plot3( ...
        osi, ...
        centr(1), centr(2), centr(3), ...
        'p', ...
        'MarkerSize', 10, ...
        'MarkerFaceColor', [0.15, 0.55, 0.15], ...
        'MarkerEdgeColor', [0.1, 0.3, 0.1]);
end
end

function trajektorii = narisovat_traektorii(osi, dannye_vizualizacii)
chislo_bvs = numel(dannye_vizualizacii.id_bvs);
chislo_kadrov = numel(dannye_vizualizacii.kadry);
trajektorii = gobjects(1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
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

    trajektorii(nomer_bvs) = plot3( ...
        osi, x, y, z, ...
        'Color', [0.55, 0.55, 0.55], ...
        'LineWidth', 0.9);
end
end

function golovnye_bvs = narisovat_golovnye_bvs(osi, kadr, id_bvs)
indeksy = nayti_indeksy_golovnyh_bvs(kadr.golovnye_bvs, id_bvs);
polozheniya = poluchit_polozheniya_po_indeksam(kadr.polozheniya_bvs, indeksy);
golovnye_bvs = scatter3( ...
    osi, ...
    polozheniya(:, 1), ...
    polozheniya(:, 2), ...
    polozheniya(:, 3), ...
    140, ...
    'd', ...
    'MarkerEdgeColor', [0.1, 0.1, 0.1], ...
    'MarkerFaceColor', [0.95, 0.85, 0.10], ...
    'LineWidth', 1.2);
end

function linii_svyazi = narisovat_linii_svyazi(osi, kadr)
matrica_smeznosti = logical(kadr.matrica_smeznosti);
[stroki, stolbcy] = find(triu(matrica_smeznosti, 1));
chislo_linii = numel(stroki);

if chislo_linii == 0
    linii_svyazi = gobjects(0);
    return
end

linii_svyazi = gobjects(1, chislo_linii);
for nomer_linii = 1:chislo_linii
    pervaya_tochka = kadr.polozheniya_bvs(stroki(nomer_linii), :);
    vtoraya_tochka = kadr.polozheniya_bvs(stolbcy(nomer_linii), :);
    linii_svyazi(nomer_linii) = plot3( ...
        osi, ...
        [pervaya_tochka(1), vtoraya_tochka(1)], ...
        [pervaya_tochka(2), vtoraya_tochka(2)], ...
        [pervaya_tochka(3), vtoraya_tochka(3)], ...
        'Color', [0.20, 0.55, 0.90], ...
        'LineWidth', 1.2);
end
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

function indeksy = nayti_indeksy_golovnyh_bvs(golovnye_bvs, id_bvs)
indeksy = [];
for nomer_golovnogo = 1:numel(golovnye_bvs)
    id_golovnogo = char(string(golovnye_bvs{nomer_golovnogo}));
    if strlength(string(id_golovnogo)) == 0
        continue
    end

    indeks = find(strcmp(id_bvs, id_golovnogo), 1);
    if ~isempty(indeks)
        indeksy(end + 1) = indeks; %#ok<AGROW>
    end
end
end

function polozheniya = poluchit_polozheniya_po_indeksam(vse_polozheniya, indeksy)
if isempty(indeksy)
    polozheniya = nan(1, 3);
else
    polozheniya = vse_polozheniya(indeksy, :);
end
end

function tekst = poluchit_podpis_sobytii(sobytiya)
if isempty(sobytiya)
    tekst = 'События передачи: нет.';
    return
end

stroki = cell(1, min(numel(sobytiya), 3));
for nomer_stroki = 1:numel(stroki)
    sobytie = sobytiya(nomer_stroki);
    stroki{nomer_stroki} = sprintf( ...
        '%s: %s', ...
        sobytie.id_soobshcheniya, ...
        sobytie.tip_sobytiya);
end

if numel(sobytiya) > numel(stroki)
    stroki{end + 1} = sprintf( ...
        '... и еще %d событий.', ...
        numel(sobytiya) - numel(stroki));
end

tekst = strjoin(stroki, newline);
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
    4 8];

chislo_reber = size(rebra, 1);
x = nan(chislo_reber, 3);
y = nan(chislo_reber, 3);
z = nan(chislo_reber, 3);
for nomer_rebra = 1:chislo_reber
    para = rebra(nomer_rebra, :);
    x(nomer_rebra, 1:2) = vershiny(para, 1);
    y(nomer_rebra, 1:2) = vershiny(para, 2);
    z(nomer_rebra, 1:2) = vershiny(para, 3);
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
    granicy.xmin, granicy.ymax, granicy.zmax];
end

function grani = poluchit_grani_parallelepipeda()
grani = [ ...
    1 2 3 4
    5 6 7 8
    1 2 6 5
    2 3 7 6
    3 4 8 7
    4 1 5 8];
end

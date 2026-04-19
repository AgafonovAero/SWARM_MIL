function grafika = obnovit_kadr_roya(grafika, dannye_vizualizacii, nomer_kadra)
if nargin < 3
    error('%s', ...
        'Для обновления кадра требуются графика, данные визуализации и номер кадра.');
end

if ~isstruct(grafika) || ~isfield(grafika, 'figura') || ~isgraphics(grafika.figura)
    error('%s', 'Графическая сцена для обновления кадра задана некорректно.');
end

if nomer_kadra < 1 || nomer_kadra > numel(dannye_vizualizacii.kadry)
    error('%s', sprintf( ...
        'Номер кадра %d выходит за границы подготовленных данных.', ...
        nomer_kadra));
end

kadr = dannye_vizualizacii.kadry(nomer_kadra);
cveta_bvs = poluchit_cveta_bvs(kadr, numel(dannye_vizualizacii.id_bvs));

set(grafika.tochki_bvs, ...
    'XData', kadr.polozheniya_bvs(:, 1), ...
    'YData', kadr.polozheniya_bvs(:, 2), ...
    'ZData', kadr.polozheniya_bvs(:, 3), ...
    'CData', cveta_bvs);

for nomer_bvs = 1:numel(grafika.podpisi_bvs)
    set(grafika.podpisi_bvs(nomer_bvs), ...
        'Position', kadr.polozheniya_bvs(nomer_bvs, :));
end

if ~isempty(grafika.linii_svyazi)
    validnye_linii = grafika.linii_svyazi(isgraphics(grafika.linii_svyazi));
    if ~isempty(validnye_linii)
        delete(validnye_linii);
    end
end
grafika.linii_svyazi = narisovat_linii_svyazi(grafika.osi, kadr);

indeksy_golovnyh = nayti_indeksy_golovnyh_bvs( ...
    kadr.golovnye_bvs, ...
    dannye_vizualizacii.id_bvs);
polozheniya_golovnyh = poluchit_polozheniya_po_indeksam( ...
    kadr.polozheniya_bvs, ...
    indeksy_golovnyh);
set(grafika.golovnye_bvs, ...
    'XData', polozheniya_golovnyh(:, 1), ...
    'YData', polozheniya_golovnyh(:, 2), ...
    'ZData', polozheniya_golovnyh(:, 3));

set(grafika.podpis_vremeni, ...
    'String', sprintf('Сцена роя БВС, t = %.2f с', kadr.vremya));
set(grafika.podpis_sobytii, ...
    'String', poluchit_podpis_sobytii(kadr.sobytiya_peredachi));

grafika.poslednii_kadr = nomer_kadra;
drawnow limitrate nocallbacks
end

function cveta_bvs = poluchit_cveta_bvs(kadr, chislo_bvs)
cveta_bvs = repmat([0.00, 0.45, 0.74], chislo_bvs, 1);
palitra = lines(max(numel(kadr.zvenya), 1));

for nomer_zvena = 1:numel(kadr.zvenya)
    indeksy = kadr.zvenya(nomer_zvena).indeksy_bvs;
    cveta_bvs(indeksy, :) = repmat(palitra(nomer_zvena, :), numel(indeksy), 1);
end
end

function linii_svyazi = narisovat_linii_svyazi(osi, kadr)
matrica_smeznosti = logical(kadr.matrica_smeznosti);
[stroki, stolbcy] = find(triu(matrica_smeznosti, 1));

if isempty(stroki)
    linii_svyazi = gobjects(0);
    return
end

linii_svyazi = gobjects(1, numel(stroki));
for nomer_linii = 1:numel(stroki)
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

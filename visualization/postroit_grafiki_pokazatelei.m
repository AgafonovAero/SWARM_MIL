function grafiki = postroit_grafiki_pokazatelei(dannye_vizualizacii, vidimaya_figura)
if nargin < 1 || ~isstruct(dannye_vizualizacii)
    error('%s', 'Для построения графиков требуются данные визуализации.');
end

if nargin < 2
    vidimaya_figura = true;
end

rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura);
vremya = dannye_vizualizacii.vremya(:).';
pokazateli = dannye_vizualizacii.pokazateli;

figura = figure( ...
    'Name', 'Графики показателей роя', ...
    'NumberTitle', 'off', ...
    'Visible', rezhim_vidimosti, ...
    'Color', 'w');
maket = tiledlayout(figura, 3, 3, 'Padding', 'compact', 'TileSpacing', 'compact');

osi = gobjects(1, 9);

osi(1) = nexttile(maket);
plot(osi(1), vremya, pokazateli.chislo_linii_po_vremeni, 'LineWidth', 1.3);
title(osi(1), 'Число линий связи');
xlabel(osi(1), 'Время, с');
ylabel(osi(1), 'Линии');
grid(osi(1), 'on');

osi(2) = nexttile(maket);
plot(osi(2), vremya, pokazateli.srednyaya_stepen_po_vremeni, 'LineWidth', 1.3);
title(osi(2), 'Средняя степень БВС');
xlabel(osi(2), 'Время, с');
ylabel(osi(2), 'Степень');
grid(osi(2), 'on');

osi(3) = nexttile(maket);
plot(osi(3), vremya, pokazateli.chislo_zvenev_po_vremeni, 'LineWidth', 1.3);
title(osi(3), 'Число звеньев');
xlabel(osi(3), 'Время, с');
ylabel(osi(3), 'Звенья');
grid(osi(3), 'on');

osi(4) = nexttile(maket);
plot(osi(4), vremya, pokazateli.chislo_odinochnyh_zvenev_po_vremeni, ...
    'LineWidth', 1.3);
title(osi(4), 'Число одиночных звеньев');
xlabel(osi(4), 'Время, с');
ylabel(osi(4), 'Одиночные звенья');
grid(osi(4), 'on');

osi(5) = nexttile(maket);
plot(osi(5), vremya, pokazateli.dolya_dostavlennyh_po_vremeni, 'LineWidth', 1.3);
title(osi(5), 'Доля доставленных сообщений');
xlabel(osi(5), 'Время, с');
ylabel(osi(5), 'Доля');
ylim(osi(5), [0, 1]);
grid(osi(5), 'on');

osi(6) = nexttile(maket);
plot(osi(6), vremya, pokazateli.nakoplennoe_chislo_dostavlennyh, 'LineWidth', 1.3);
title(osi(6), 'Накопленное число доставленных');
xlabel(osi(6), 'Время, с');
ylabel(osi(6), 'Сообщения');
grid(osi(6), 'on');

osi(7) = nexttile(maket);
plot(osi(7), vremya, pokazateli.nakoplennoe_chislo_poteryannyh, 'LineWidth', 1.3);
title(osi(7), 'Накопленное число потерянных');
xlabel(osi(7), 'Время, с');
ylabel(osi(7), 'Сообщения');
grid(osi(7), 'on');

osi(8) = nexttile(maket);
plot(osi(8), vremya, pokazateli.srednyaya_zaderzhka_dostavki_po_vremeni, ...
    'LineWidth', 1.3);
title(osi(8), 'Средняя задержка доставки');
xlabel(osi(8), 'Время, с');
ylabel(osi(8), 'Секунды');
grid(osi(8), 'on');

osi(9) = nexttile(maket);
plot(osi(9), vremya, pokazateli.srednee_chislo_peresylok_po_vremeni, ...
    'LineWidth', 1.3);
title(osi(9), 'Среднее число пересылок');
xlabel(osi(9), 'Время, с');
ylabel(osi(9), 'Пересылки');
grid(osi(9), 'on');

grafiki = struct();
grafiki.figura = figura;
grafiki.maket = maket;
grafiki.osi = osi;
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
        'Признак видимости графиков должен быть логическим скалярным значением.');
end
end

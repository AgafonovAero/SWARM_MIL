function grafiki = postroit_grafiki_serii_opytov(rezultat_serii, vidimaya_figura, papka_sohraneniya)
if nargin < 1 || ~isstruct(rezultat_serii) ...
        || ~isfield(rezultat_serii, 'tablica_sravneniya')
    error('%s', ...
        'Для построения графиков серии требуется структура результата серии.');
end

if nargin < 2
    vidimaya_figura = true;
end

if nargin < 3
    papka_sohraneniya = '';
end

tablica = rezultat_serii.tablica_sravneniya;
if ~istable(tablica) || height(tablica) == 0
    error('%s', ...
        'Таблица сравнения серии должна быть непустой таблицей.');
end

rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura);
podpisi = sostavit_podpisi_variantov(tablica);

figura = figure( ...
    'Name', 'Сравнительные графики серии опытов', ...
    'NumberTitle', 'off', ...
    'Visible', rezhim_vidimosti, ...
    'Color', 'w');
maket = tiledlayout(figura, 3, 3, 'Padding', 'compact', 'TileSpacing', 'compact');
osi = gobjects(1, 8);

osi(1) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.dolya_vremeni_svyaznogo_roya, ...
    'Доля времени связного роя', 'Доля');
osi(2) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednee_chislo_linii, ...
    'Среднее число линий связи', 'Линии');
osi(3) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednee_chislo_zvenev, ...
    'Среднее число звеньев', 'Звенья');
osi(4) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.dolya_dostavlennyh_soobshchenii, ...
    'Доля доставленных сообщений', 'Доля');
osi(5) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednyaya_zaderzhka_dostavki_s, ...
    'Средняя задержка доставки', 'Секунды');
osi(6) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednee_chislo_peresylok, ...
    'Среднее число пересылок', 'Пересылки');
osi(7) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.vremya_vypolneniya_s, ...
    'Время выполнения опыта', 'Секунды');
osi(8) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednyaya_stepen_bvs, ...
    'Средняя степень БВС', 'Степень');

puti_k_failam = {};
if strlength(string(papka_sohraneniya)) > 0
    if ~isfolder(papka_sohraneniya)
        mkdir(papka_sohraneniya);
    end

    put_k_failu = fullfile(papka_sohraneniya, 'series_metrics.png');
    exportgraphics(figura, put_k_failu, 'Resolution', 150);
    puti_k_failam = {put_k_failu};
end

grafiki = struct();
grafiki.figury = figura;
grafiki.maket = maket;
grafiki.osi = osi;
grafiki.puti_k_failam = puti_k_failam;
end

function os = postroit_stolbcovyj_grafik(maket, podpisi, znacheniya, zagolovok, metka_osi)
os = nexttile(maket);
bar(os, znacheniya, 'FaceColor', [0.2 0.5 0.8]);
title(os, zagolovok);
ylabel(os, metka_osi);
xticks(os, 1:numel(podpisi));
xticklabels(os, podpisi);
xtickangle(os, 20);
grid(os, 'on');
end

function podpisi = sostavit_podpisi_variantov(tablica)
podpisi = strings(height(tablica), 1);
for nomer_stroki = 1:height(tablica)
    podpisi(nomer_stroki) = string(tablica.id_varianta{nomer_stroki});
end
end

function rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura)
if ~islogical(vidimaya_figura) || ~isscalar(vidimaya_figura)
    error('%s', ...
        'Признак видимости графиков серии должен быть логическим скаляром.');
end

if vidimaya_figura
    rezhim_vidimosti = 'on';
else
    rezhim_vidimosti = 'off';
end
end

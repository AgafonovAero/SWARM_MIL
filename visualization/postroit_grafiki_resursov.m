function grafiki = postroit_grafiki_resursov(rezultat_resursov_opyta, rezultat_resursov_serii, vidimaya_figura, papka_sohraneniya)
if nargin < 2
    error('%s', [ ...
        'Для построения графиков ресурсов требуются результат ресурсов ' ...
        'одного опыта и ресурсная сводка серии.' ...
        ]);
end

if nargin < 3
    vidimaya_figura = true;
end

if nargin < 4
    papka_sohraneniya = '';
end

rezultat_resursov_opyta = proverit_rezultat_resursov_opyta(rezultat_resursov_opyta);
rezultat_resursov_serii = proverit_rezultat_resursov_serii(rezultat_resursov_serii);
rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura);

figura_energii = figure( ...
    'Name', 'Графики ресурсов: энергия по БВС', ...
    'NumberTitle', 'off', ...
    'Visible', rezhim_vidimosti, ...
    'Color', 'w');
os_energii = axes(figura_energii);
plot(os_energii, rezultat_resursov_opyta.vremya, rezultat_resursov_opyta.energiya_po_vremeni, 'LineWidth', 1.2);
grid(os_energii, 'on');
title(os_energii, 'Остаток энергии по БВС');
xlabel(os_energii, 'Время, с');
ylabel(os_energii, 'Энергия, Дж');
legend(os_energii, rezultat_resursov_opyta.id_bvs, 'Location', 'bestoutside');

tablica = rezultat_resursov_serii.tablica_resursov;
podpisi = string(tablica.id_varianta);

figura_serii = figure( ...
    'Name', 'Графики ресурсов: сравнение вариантов', ...
    'NumberTitle', 'off', ...
    'Visible', rezhim_vidimosti, ...
    'Color', 'w');
maket = tiledlayout(figura_serii, 2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
osi = gobjects(1, 4);
osi(1) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.summarnyi_rashod_energii, ...
    'Суммарный расход энергии по вариантам', 'Дж');
osi(2) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.maksimalnaya_nagruzka_golovnogo_bvs, ...
    'Максимальная нагрузка головного БВС', 'Доля');
osi(3) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.srednyaya_zanyatost_ocheredi, ...
    'Средняя занятость очередей', 'Доля');
osi(4) = postroit_stolbcovyj_grafik( ...
    maket, podpisi, tablica.dolya_bvs_s_dostatochnoi_energiey, ...
    'Доля БВС с достаточной энергией', 'Доля');

puti_k_failam = {};
if strlength(string(papka_sohraneniya)) > 0
    if ~isfolder(papka_sohraneniya)
        mkdir(papka_sohraneniya);
    end

    put_k_energii = fullfile(papka_sohraneniya, 'resource_energy.png');
    put_k_serii = fullfile(papka_sohraneniya, 'resource_series.png');
    exportgraphics(figura_energii, put_k_energii, 'Resolution', 150);
    exportgraphics(figura_serii, put_k_serii, 'Resolution', 150);
    puti_k_failam = {put_k_energii, put_k_serii};
end

grafiki = struct();
grafiki.figury = [figura_energii, figura_serii];
grafiki.osi = [os_energii, osi];
grafiki.puti_k_failam = puti_k_failam;
end

function rezultat_resursov_opyta = proverit_rezultat_resursov_opyta(rezultat_resursov_opyta)
if ~isstruct(rezultat_resursov_opyta) ...
        || ~isfield(rezultat_resursov_opyta, 'vremya') ...
        || ~isfield(rezultat_resursov_opyta, 'energiya_po_vremeni') ...
        || ~isfield(rezultat_resursov_opyta, 'id_bvs')
    error('%s', [ ...
        'Результат ресурсов одного опыта должен содержать временную ось, ' ...
        'энергию по времени и идентификаторы БВС.' ...
        ]);
end
end

function rezultat_resursov_serii = proverit_rezultat_resursov_serii(rezultat_resursov_serii)
if ~isstruct(rezultat_resursov_serii) ...
        || ~isfield(rezultat_resursov_serii, 'tablica_resursov')
    error('%s', ...
        'Ресурсная сводка серии должна содержать таблицу ресурсов.');
end
end

function os = postroit_stolbcovyj_grafik(maket, podpisi, znacheniya, zagolovok, metka_osi)
os = nexttile(maket);
bar(os, znacheniya, 'FaceColor', [0.25 0.55 0.75]);
title(os, zagolovok);
ylabel(os, metka_osi);
xticks(os, 1:numel(podpisi));
xticklabels(os, podpisi);
xtickangle(os, 20);
grid(os, 'on');
end

function rezhim_vidimosti = poluchit_rezhim_vidimosti(vidimaya_figura)
if ~islogical(vidimaya_figura) || ~isscalar(vidimaya_figura)
    error('%s', ...
        'Признак видимости графиков ресурсов должен быть логическим скаляром.');
end

if vidimaya_figura
    rezhim_vidimosti = 'on';
else
    rezhim_vidimosti = 'off';
end
end

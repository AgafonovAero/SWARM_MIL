function zapusk_proverok()
koren_proekta = fileparts(mfilename('fullpath'));

addpath(fullfile(koren_proekta, 'raschet', 'otsenka'));
addpath(fullfile(koren_proekta, 'raschet', 'bvs'));
addpath(fullfile(koren_proekta, 'raschet', 'sreda'));
addpath(fullfile(koren_proekta, 'raschet', 'svyaz'));
addpath(fullfile(koren_proekta, 'raschet', 'zveno'));
addpath(fullfile(koren_proekta, 'raschet', 'peredacha'));
addpath(fullfile(koren_proekta, 'raschet', 'opyty'));
addpath(fullfile(koren_proekta, 'raschet', 'resursy'));
addpath(fullfile(koren_proekta, 'raschet', 'scenarii'));
addpath(fullfile(koren_proekta, 'visualization'));
addpath(fullfile(koren_proekta, 'apps'));
addpath(fullfile(koren_proekta, 'bloki', 'sozdanie_modelei'));
addpath(fullfile(koren_proekta, 'proverki', 'edinichnye'));

try
    soobshchenie([ ...
        'Начат запуск проверок этапов 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, ' ...
        '10 и 11.' ...
        ]);

    proverka_struktury_proekta(koren_proekta);
    proverit_zapis_v_rezultaty(koren_proekta);
    vyvesti_svedeniya_o_sredah();
    soobshchenie('Проверки этапа 0 завершены успешно');

    proverka_dokumentov_etapa_1(koren_proekta);
    proverka_skrytyh_znakov(koren_proekta);
    proverka_fizicheskogo_formata_tekstov(koren_proekta);
    proverka_razmetki_markdown(koren_proekta);
    soobshchenie('Проверки этапа 1 завершены успешно');

    proverka_dokumentov_etapa_2(koren_proekta);
    proverka_scenariev_etapa_2(koren_proekta);
    soobshchenie('Проверки этапа 2 завершены успешно');

    proverka_kinematiki_etapa_3(koren_proekta);
    soobshchenie('Проверки этапа 3 завершены успешно');

    proverka_svyazi_etapa_4(koren_proekta);
    soobshchenie('Проверки этапа 4 завершены успешно');

    proverka_zvenev_etapa_5(koren_proekta);
    soobshchenie('Проверки этапа 5 завершены успешно');

    proverka_peredachi_etapa_6(koren_proekta);
    soobshchenie('Проверки этапа 6 завершены успешно');

    proverka_vizualizacii_etapa_7(koren_proekta);
    soobshchenie('Проверки этапа 7 завершены успешно');

    proverka_pulta_etapa_8(koren_proekta);
    soobshchenie('Проверки этапа 8 завершены успешно');

    proverka_simulink_stenda_etapa_9(koren_proekta);
    soobshchenie('Проверки этапа 9 завершены успешно');

    proverka_serii_opytov_etapa_10(koren_proekta);
    soobshchenie('Проверки этапа 10 завершены успешно');

    proverka_resursov_etapa_11(koren_proekta);
    soobshchenie('Проверки этапа 11 завершены успешно');
catch oshibka_proverki
    soobshchenie(sprintf( ...
        'Проверки проекта завершены с ошибкой: %s', ...
        oshibka_proverki.message), ...
        'oshibka');
    rethrow(oshibka_proverki);
end
end

function proverit_zapis_v_rezultaty(koren_proekta)
papka_rezultatov = fullfile(koren_proekta, 'opyty', 'rezultaty');
metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
imya_vremennogo_faila = ['proverka_zapisi_' metka_vremeni '.txt'];
put_k_failu = fullfile(papka_rezultatov, imya_vremennogo_faila);

[identifikator, tekst_oshibki] = fopen(put_k_failu, 'w');
if identifikator == -1
    error('%s', sprintf( ...
        'Нет возможности записи в папку результатов %s. Причина: %s', ...
        papka_rezultatov, ...
        tekst_oshibki));
end

ochistka_faila = onCleanup(@() bezopasno_zakryt_fail(identifikator));
fprintf(identifikator, 'Проверка записи этапа 0.%s', newline);
clear ochistka_faila

if ~isfile(put_k_failu)
    error('%s', sprintf( ...
        'Не создан временный файл проверки записи: %s', ...
        put_k_failu));
end

try
    delete(put_k_failu);
catch oshibka_udaleniya
    error('%s', sprintf([ ...
        'Не удалось удалить временный файл проверки записи: %s.%s' ...
        'Причина: %s' ...
        ], ...
        put_k_failu, ...
        newline, ...
        oshibka_udaleniya.message));
end

if isfile(put_k_failu)
    error('%s', sprintf( ...
        'Не удалось удалить временный файл проверки записи: %s', ...
        put_k_failu));
end

soobshchenie('Папка результатов доступна для записи.');
end

function vyvesti_svedeniya_o_sredah()
svedeniya_o_matlab = ver('MATLAB');
if isempty(svedeniya_o_matlab)
    error('%s', 'Не удалось получить сведения о MATLAB.');
end

svedeniya_o_simulink = ver('Simulink');
if isempty(svedeniya_o_simulink)
    error('%s', 'Не удалось получить сведения о Simulink.');
end

soobshchenie(sprintf( ...
    'Расчетная среда MATLAB: выпуск %s, версия %s.', ...
    svedeniya_o_matlab.Release, ...
    svedeniya_o_matlab.Version));
soobshchenie(sprintf( ...
    'Блочная среда Simulink: выпуск %s, версия %s.', ...
    svedeniya_o_simulink.Release, ...
    svedeniya_o_simulink.Version));
end

function bezopasno_zakryt_fail(identifikator)
if identifikator ~= -1
    fclose(identifikator);
end
end

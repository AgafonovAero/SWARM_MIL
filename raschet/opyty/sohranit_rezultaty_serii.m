function put_k_papke = sohranit_rezultaty_serii(koren_proekta, rezultat_serii)
if nargin < 2
    error('%s', ...
        'Для сохранения результатов серии требуются корень проекта и структура результата.');
end

if ~isstruct(rezultat_serii) || ~isfield(rezultat_serii, 'id_serii')
    error('%s', 'Результат серии должен содержать идентификатор серии.');
end

metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
imya_papki = sprintf('%s_%s', rezultat_serii.id_serii, metka_vremeni);
put_k_papke = fullfile(koren_proekta, 'opyty', 'rezultaty', 'serii', imya_papki);

if ~isfolder(put_k_papke)
    mkdir(put_k_papke);
end

save(fullfile(put_k_papke, 'result.mat'), 'rezultat_serii');
zapisat_json(fullfile(put_k_papke, 'metrics.json'), rezultat_serii.tablica_sravneniya);
zapisat_json(fullfile(put_k_papke, 'plan_used.json'), rezultat_serii.plan_serii);
zapisat_utf8_fail(fullfile(put_k_papke, 'summary.md'), ...
    sobrat_summary_serii(rezultat_serii));
end

function tekst = sobrat_summary_serii(rezultat_serii)
tablica = rezultat_serii.tablica_sravneniya;
chislo_variantov = height(tablica);
chislo_bvs = mean(tablica.chislo_bvs);
dolya_svyaznosti = mean(tablica.dolya_vremeni_svyaznogo_roya);
chislo_zvenev = mean(tablica.srednee_chislo_zvenev);
dolya_dostavki = mean(tablica.dolya_dostavlennyh_soobshchenii);

stroki = {
    '# Сводный отчет серии опытов'
    ''
    ['- Серия: `' rezultat_serii.id_serii '`.']
    ['- Число вариантов: ' num2str(chislo_variantov) '.']
    ['- Среднее число БВС: ' num2str(chislo_bvs, '%.2f') '.']
    ['- Средняя доля времени связного роя: ' num2str(dolya_svyaznosti, '%.4f') '.']
    ['- Среднее число звеньев: ' num2str(chislo_zvenev, '%.4f') '.']
    ['- Средняя доля доставленных сообщений: ' num2str(dolya_dostavki, '%.4f') '.']
    ''
    '## Ограничения серии'
    ''
    '- используются уже реализованные расчетные слои этапов 3–9;'
    '- управление, обучение и распределение ресурсов не реализуются;'
    '- результаты серии предназначены для исследовательского сравнения параметров.'
    };

tekst = strjoin(stroki, newline);
end

function zapisat_json(put_k_failu, dannye)
if istable(dannye)
    dannye = table2struct(dannye);
end

try
    tekst_json = jsonencode(dannye, PrettyPrint=true);
catch
    tekst_json = jsonencode(dannye);
end

zapisat_utf8_fail(put_k_failu, tekst_json);
end

function zapisat_utf8_fail(put_k_failu, tekst)
[identifikator, tekst_oshibki] = fopen(put_k_failu, 'w', 'n', 'UTF-8');
if identifikator == -1
    error('%s', sprintf( ...
        'Не удалось открыть файл %s для записи. Причина: %s', ...
        put_k_failu, ...
        tekst_oshibki));
end

ochistka = onCleanup(@() fclose(identifikator));
fprintf(identifikator, '%s', tekst);
clear ochistka
end

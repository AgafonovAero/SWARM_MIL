function put_k_papke = sohranit_rezultaty_serii(koren_proekta, rezultat_serii)
if nargin < 2
    error('%s', ...
        'Для сохранения результатов серии требуются корень проекта и структура результата.');
end

if ~isstruct(rezultat_serii) || ~isfield(rezultat_serii, 'id_serii')
    error('%s', 'Результат серии должен содержать идентификатор серии.');
end

if isfield(rezultat_serii, 'papka_rezultatov') ...
        && strlength(string(rezultat_serii.papka_rezultatov)) > 0
    put_k_papke = char(string(rezultat_serii.papka_rezultatov));
else
    metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
    imya_papki = sprintf('%s_%s', rezultat_serii.id_serii, metka_vremeni);
    put_k_papke = fullfile(koren_proekta, 'opyty', 'rezultaty', 'serii', imya_papki);
end

if ~isfolder(put_k_papke)
    mkdir(put_k_papke);
end

save(fullfile(put_k_papke, 'result.mat'), 'rezultat_serii');
zapisat_json(fullfile(put_k_papke, 'metrics.json'), rezultat_serii.tablica_sravneniya);
zapisat_json(fullfile(put_k_papke, 'plan_used.json'), rezultat_serii.plan_serii);
if isfield(rezultat_serii, 'resursnaya_svodka')
    zapisat_json( ...
        fullfile(put_k_papke, 'resources.json'), ...
        podgotovit_dannye_resursov_k_sohraneniyu(rezultat_serii.resursnaya_svodka));
end
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
    '## Сохраненные файлы'
    ''
    '- `result.mat`;'
    '- `metrics.json`;'
    '- `plan_used.json`;'
    '- `summary.md`.'
    ''
    '## Ограничения серии'
    ''
    '- используются уже реализованные расчетные слои этапов 3–10;'
    '- управление, обучение и распределение ресурсов не реализуются;'
    '- результаты серии предназначены для исследовательского сравнения параметров.'
    };

if isfield(rezultat_serii, 'resursnaya_svodka')
    srednii_ostatok = mean( ...
        rezultat_serii.resursnaya_svodka.tablica_resursov.srednii_ostatok_energii);
    stroki = [stroki; { ...
        ''
        '## Ресурсная сводка'
        ''
        ['- Средний остаток энергии по вариантам: ' num2str(srednii_ostatok, '%.4f') '.']
        '- Сохранен файл `resources.json`.'
        }]; %#ok<AGROW>
end

if isfield(rezultat_serii, 'resursnaya_svodka') ...
        && isfield(rezultat_serii.resursnaya_svodka, 'chislo_dopustimyh_variantov')
    chislo_dopustimyh = rezultat_serii.resursnaya_svodka.chislo_dopustimyh_variantov;
    chislo_nedopustimyh = rezultat_serii.resursnaya_svodka.chislo_nedopustimyh_variantov;
    stroki = [stroki; { ...
        ''
        '## Ресурсная допустимость'
        ''
        ['- Ресурсно допустимых вариантов: ' num2str(chislo_dopustimyh) '.']
        ['- Ресурсно недопустимых вариантов: ' num2str(chislo_nedopustimyh) '.']
        }]; %#ok<AGROW>

    osnovnye_prichiny = rezultat_serii.resursnaya_svodka.osnovnye_prichiny_narushenii;
    if isempty(osnovnye_prichiny)
        stroki = [stroki; {'- Нарушения ресурсной допустимости не обнаружены.'}]; %#ok<AGROW>
    else
        stroki = [stroki; {'- Основные причины нарушений:'}]; %#ok<AGROW>
        for nomer_prichiny = 1:numel(osnovnye_prichiny)
            stroki{end + 1} = ['- ' osnovnye_prichiny{nomer_prichiny}]; %#ok<AGROW>
        end
    end
end

if isfield(rezultat_serii, 'puti_k_grafikam_resursov') ...
        && ~isempty(rezultat_serii.puti_k_grafikam_resursov)
    stroki = [stroki; { ...
        ''
        '## Графики ресурсов'
        ''
        '- В папке серии сохранены графики ресурсных показателей в формате `.png`.'
        }]; %#ok<AGROW>
end

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

function dannye = podgotovit_dannye_resursov_k_sohraneniyu(resursnaya_svodka)
dannye = struct();
dannye.tablica_resursov = table2struct(resursnaya_svodka.tablica_resursov);

if isfield(resursnaya_svodka, 'opisaniya_narushenii_po_variantam')
    dannye.opisaniya_narushenii_po_variantam = ...
        resursnaya_svodka.opisaniya_narushenii_po_variantam;
end

if isfield(resursnaya_svodka, 'chislo_dopustimyh_variantov')
    dannye.chislo_dopustimyh_variantov = ...
        resursnaya_svodka.chislo_dopustimyh_variantov;
end

if isfield(resursnaya_svodka, 'chislo_nedopustimyh_variantov')
    dannye.chislo_nedopustimyh_variantov = ...
        resursnaya_svodka.chislo_nedopustimyh_variantov;
end

if isfield(resursnaya_svodka, 'osnovnye_prichiny_narushenii')
    dannye.osnovnye_prichiny_narushenii = ...
        resursnaya_svodka.osnovnye_prichiny_narushenii;
end
end

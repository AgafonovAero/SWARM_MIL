function [id_golovnogo_bvs, ocenki_kandidatov] = vybrat_golovnoi_bvs(spisok_bvs_zvena, graf_svyaznosti, sostoyaniya_bvs, parametry_zvenev)

if nargin < 4
    error('%s', [ ...
        'Для выбора головного БВС требуются список участников звена, ' ...
        'граф связности, состояния БВС и параметры звеньев.' ...
        ]);
end

parametry_zvenev = proverit_parametry_zvenev(parametry_zvenev);
[id_bvs, matrica_smeznosti, matrica_poleznosti_linii, ...
    matrica_rasstoyanii_m] = izvliek_dannye_grafa(graf_svyaznosti);
identifikatory_zvena = normalizovat_spisok_bvs_zvena(spisok_bvs_zvena);
indeksy_zvena = nayti_indeksy_zvena(identifikatory_zvena, id_bvs);
spravochnik_sostoyanii = postroit_spravochnik_sostoyanii(sostoyaniya_bvs);

chislo_uchastnikov = numel(indeksy_zvena);
stepen_syra = zeros(1, chislo_uchastnikov);
poleznost_syra = zeros(1, chislo_uchastnikov);
centralnost_syra = zeros(1, chislo_uchastnikov);
energiya_syra = nan(1, chislo_uchastnikov);
primechaniya = repmat({{}}, 1, chislo_uchastnikov);

podmatrica_smeznosti = matrica_smeznosti(indeksy_zvena, indeksy_zvena);
podmatrica_poleznosti = matrica_poleznosti_linii(indeksy_zvena, indeksy_zvena);
podmatrica_rasstoyanii = matrica_rasstoyanii_m(indeksy_zvena, indeksy_zvena);

for nomer_uchastnika = 1:chislo_uchastnikov
    tekushchii_id = identifikatory_zvena{nomer_uchastnika};
    stepen_syra(nomer_uchastnika) = sum(podmatrica_smeznosti(nomer_uchastnika, :));

    if chislo_uchastnikov == 1
        primechaniya{nomer_uchastnika}{end + 1} = [ ...
            'В звене один участник, показатели связей и центральности ' ...
            'приняты равными нулю.' ...
            ];
    else
        maska_sosedey = true(1, chislo_uchastnikov);
        maska_sosedey(nomer_uchastnika) = false;
        poleznost_syra(nomer_uchastnika) = mean( ...
            podmatrica_poleznosti(nomer_uchastnika, maska_sosedey));

        rasstoyaniya = podmatrica_rasstoyanii(nomer_uchastnika, maska_sosedey);
        konechnye_rasstoyaniya = rasstoyaniya(isfinite(rasstoyaniya) & rasstoyaniya > 0);
        if isempty(konechnye_rasstoyaniya)
            primechaniya{nomer_uchastnika}{end + 1} = [ ...
                'Нет данных о расстояниях внутри звена, центральность ' ...
                'принята равной нулю.' ...
                ];
        else
            centralnost_syra(nomer_uchastnika) = 1 / mean(konechnye_rasstoyaniya);
        end
    end

    if isfield(spravochnik_sostoyanii, tekushchii_id)
        energiia = spravochnik_sostoyanii.(tekushchii_id).zapas_energii;
        if isfinite(energiia)
            energiya_syra(nomer_uchastnika) = double(energiia);
        else
            primechaniya{nomer_uchastnika}{end + 1} = [ ...
                'Запас энергии имеет некорректное значение, использован ' ...
                'безопасный ноль.' ...
                ];
            energiya_syra(nomer_uchastnika) = 0;
        end
    else
        primechaniya{nomer_uchastnika}{end + 1} = [ ...
            'Нет данных о запасе энергии, использовано нулевое значение.' ...
            ];
        energiya_syra(nomer_uchastnika) = 0;
    end
end

normalizovannaya_stepen = normalizovat_pokazateli(stepen_syra);
normalizovannaya_poleznost = normalizovat_pokazateli(poleznost_syra);
normalizovannaya_centralnost = normalizovat_pokazateli(centralnost_syra);
normalizovannaya_energiya = normalizovat_pokazateli(energiya_syra);

summa_vesov = parametry_zvenev.ves_stepeni_bvs ...
    + parametry_zvenev.ves_poleznosti_linii ...
    + parametry_zvenev.ves_centralnosti ...
    + parametry_zvenev.ves_zapasa_energii;
itogovye_ocenki = ( ...
    parametry_zvenev.ves_stepeni_bvs .* normalizovannaya_stepen ...
    + parametry_zvenev.ves_poleznosti_linii .* normalizovannaya_poleznost ...
    + parametry_zvenev.ves_centralnosti .* normalizovannaya_centralnost ...
    + parametry_zvenev.ves_zapasa_energii .* normalizovannaya_energiya) ...
    / summa_vesov;

ocenki_kandidatov = repmat(struct( ...
    'id_bvs', '', ...
    'stepen_vnutri_zvena', 0, ...
    'srednyaya_poleznost_linii', 0, ...
    'centralnost_po_rasstoyaniyu', 0, ...
    'zapas_energii', 0, ...
    'normalizovannaya_stepen', 0, ...
    'normalizovannaya_poleznost_linii', 0, ...
    'normalizovannaya_centralnost', 0, ...
    'normalizovannyi_zapas_energii', 0, ...
    'itogovaya_ocenka', 0, ...
    'primechanie', ''), 1, chislo_uchastnikov);

for nomer_uchastnika = 1:chislo_uchastnikov
    ocenki_kandidatov(nomer_uchastnika).id_bvs = identifikatory_zvena{nomer_uchastnika};
    ocenki_kandidatov(nomer_uchastnika).stepen_vnutri_zvena = ...
        stepen_syra(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).srednyaya_poleznost_linii = ...
        poleznost_syra(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).centralnost_po_rasstoyaniyu = ...
        centralnost_syra(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).zapas_energii = ...
        energiya_syra(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).normalizovannaya_stepen = ...
        normalizovannaya_stepen(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).normalizovannaya_poleznost_linii = ...
        normalizovannaya_poleznost(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).normalizovannaya_centralnost = ...
        normalizovannaya_centralnost(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).normalizovannyi_zapas_energii = ...
        normalizovannaya_energiya(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).itogovaya_ocenka = ...
        itogovye_ocenki(nomer_uchastnika);
    ocenki_kandidatov(nomer_uchastnika).primechanie = ...
        strjoin(primechaniya{nomer_uchastnika}, ' ');
end

indeks_luchshego = vybrat_luchshuyu_ocenku(identifikatory_zvena, itogovye_ocenki);
id_golovnogo_bvs = identifikatory_zvena{indeks_luchshego};
end

function [id_bvs, matrica_smeznosti, matrica_poleznosti_linii, matrica_rasstoyanii_m] = izvliek_dannye_grafa(graf_svyaznosti)
if ~isstruct(graf_svyaznosti)
    error('%s', 'Граф связности должен быть передан в виде структуры.');
end

obyazatelnye_polya = {
    'id_bvs'
    'matrica_smeznosti'
    'matrica_poleznosti_linii'
    'matrica_rasstoyanii_m'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(graf_svyaznosti, imya_polya)
        error('%s', sprintf( ...
            'В графе связности отсутствует обязательное поле %s.', ...
            imya_polya));
    end
end

id_bvs = normalizovat_spisok_bvs_zvena(graf_svyaznosti.id_bvs);
matrica_smeznosti = logical(graf_svyaznosti.matrica_smeznosti);
matrica_poleznosti_linii = double(graf_svyaznosti.matrica_poleznosti_linii);
matrica_rasstoyanii_m = double(graf_svyaznosti.matrica_rasstoyanii_m);
end

function identifikatory = normalizovat_spisok_bvs_zvena(spisok_bvs_zvena)
if isstruct(spisok_bvs_zvena)
    if ~isfield(spisok_bvs_zvena, 'id_bvs')
        error('%s', [ ...
            'Структура звена должна содержать поле id_bvs со списком ' ...
            'участников.' ...
            ]);
    end
    spisok_bvs_zvena = spisok_bvs_zvena.id_bvs;
end

if isstring(spisok_bvs_zvena)
    identifikatory = cellstr(spisok_bvs_zvena(:).');
elseif ischar(spisok_bvs_zvena)
    identifikatory = {spisok_bvs_zvena};
elseif iscell(spisok_bvs_zvena)
    identifikatory = cellfun(@(znachenie) char(string(znachenie)), ...
        spisok_bvs_zvena, 'UniformOutput', false);
else
    error('%s', 'Список БВС звена должен быть списком строк.');
end

if isempty(identifikatory)
    error('%s', 'Для выбора головного БВС звено не может быть пустым.');
end
end

function indeksy_zvena = nayti_indeksy_zvena(identifikatory_zvena, id_bvs)
indeksy_zvena = zeros(1, numel(identifikatory_zvena));

for nomer_bvs = 1:numel(identifikatory_zvena)
    indeks = find(strcmp(id_bvs, identifikatory_zvena{nomer_bvs}), 1);
    if isempty(indeks)
        error('%s', sprintf( ...
            'БВС %s отсутствует в графе связности.', ...
            identifikatory_zvena{nomer_bvs}));
    end
    indeksy_zvena(nomer_bvs) = indeks;
end
end

function spravochnik = postroit_spravochnik_sostoyanii(sostoyaniya_bvs)
spravochnik = struct();

if ~isstruct(sostoyaniya_bvs)
    error('%s', 'Состояния БВС должны быть переданы массивом структур.');
end

for nomer_bvs = 1:numel(sostoyaniya_bvs)
    sostoyanie = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));
    spravochnik.(sostoyanie.id_bvs) = sostoyanie;
end
end

function normalizovannye_znacheniya = normalizovat_pokazateli(znacheniya)
znacheniya = double(znacheniya(:).');
normalizovannye_znacheniya = zeros(size(znacheniya));

maska = isfinite(znacheniya);
if ~any(maska)
    return
end

dopustimye_znacheniya = znacheniya(maska);
minimum = min(dopustimye_znacheniya);
maksimum = max(dopustimye_znacheniya);

if maksimum <= minimum
    if maksimum > 0
        normalizovannye_znacheniya(maska) = 1;
    end
    return
end

normalizovannye_znacheniya(maska) = ...
    (znacheniya(maska) - minimum) ./ (maksimum - minimum);
normalizovannye_znacheniya = min(max(normalizovannye_znacheniya, 0), 1);
end

function indeks_luchshego = vybrat_luchshuyu_ocenku(identifikatory, itogovye_ocenki)
itogovye_ocenki = double(itogovye_ocenki(:).');
maksimalnaya_ocenka = max(itogovye_ocenki);
pretendenty = find(abs(itogovye_ocenki - maksimalnaya_ocenka) <= 1e-12);

if numel(pretendenty) == 1
    indeks_luchshego = pretendenty;
    return
end

[~, lokalnyi_indeks] = sort(identifikatory(pretendenty));
indeks_luchshego = pretendenty(lokalnyi_indeks(1));
end

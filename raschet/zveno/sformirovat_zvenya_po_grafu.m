function rezultat = sformirovat_zvenya_po_grafu(graf_svyaznosti, sostoyaniya_bvs, parametry_zvenev)

if nargin < 3
    error('%s', [ ...
        'Для формирования звеньев требуются граф связности, ' ...
        'состояния БВС и параметры звеньев.' ...
        ]);
end

parametry_zvenev = proverit_parametry_zvenev(parametry_zvenev);
[id_bvs, matrica_smeznosti, matrica_poleznosti_linii, ...
    matrica_rasstoyanii_m] = proverit_graf_svyaznosti(graf_svyaznosti);
proverit_sostoyaniya_dlya_zvenev(sostoyaniya_bvs, id_bvs);

komponenty = nayti_svyaznye_komponenty(matrica_smeznosti);
indeksy_zvenev = {};

for nomer_komponenty = 1:numel(komponenty)
    komponenta = komponenty{nomer_komponenty};
    novye_zvenya = razbit_komponentu_na_zvenya( ...
        komponenta, ...
        matrica_smeznosti, ...
        matrica_poleznosti_linii, ...
        matrica_rasstoyanii_m, ...
        parametry_zvenev);
    indeksy_zvenev = [indeksy_zvenev, novye_zvenya]; %#ok<AGROW>
end

rezultat = sobrat_rezultat_zvenev(id_bvs, indeksy_zvenev);
end

function [id_bvs, matrica_smeznosti, matrica_poleznosti_linii, matrica_rasstoyanii_m] = proverit_graf_svyaznosti(graf_svyaznosti)

if ~isstruct(graf_svyaznosti)
    error('%s', ...
        'Граф связности должен быть передан в виде структуры.');
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

id_bvs = normalizovat_id_bvs(graf_svyaznosti.id_bvs);
chislo_bvs = numel(id_bvs);

matrica_smeznosti = logical(graf_svyaznosti.matrica_smeznosti);
matrica_poleznosti_linii = double(graf_svyaznosti.matrica_poleznosti_linii);
matrica_rasstoyanii_m = double(graf_svyaznosti.matrica_rasstoyanii_m);

proverit_kvadratnuyu_matricu( ...
    matrica_smeznosti, chislo_bvs, 'matrica_smeznosti');
proverit_kvadratnuyu_matricu( ...
    matrica_poleznosti_linii, chislo_bvs, 'matrica_poleznosti_linii');
proverit_kvadratnuyu_matricu( ...
    matrica_rasstoyanii_m, chislo_bvs, 'matrica_rasstoyanii_m');

if ~isequaln(matrica_smeznosti, matrica_smeznosti.')
    error('%s', 'Матрица смежности звеньев должна быть симметричной.');
end

if any(diag(matrica_smeznosti))
    error('%s', [ ...
        'На диагонали матрицы смежности при формировании звеньев ' ...
        'не должно быть связей.' ...
        ]);
end

if ~all(isfinite(matrica_poleznosti_linii(:))) ...
        || ~all(isfinite(matrica_rasstoyanii_m(:)))
    error('%s', [ ...
        'Матрицы полезности линий и расстояний должны содержать только ' ...
        'конечные значения.' ...
        ]);
end
end

function proverit_kvadratnuyu_matricu(matrica, chislo_bvs, imya_matricy)
if ~isnumeric(matrica) && ~islogical(matrica)
    error('%s', sprintf( ...
        'Поле %s должно быть матрицей.', ...
        imya_matricy));
end

if ~ismatrix(matrica) || any(size(matrica) ~= [chislo_bvs, chislo_bvs])
    error('%s', sprintf( ...
        'Поле %s должно быть квадратной матрицей размера %d x %d.', ...
        imya_matricy, chislo_bvs, chislo_bvs));
end
end

function id_bvs = normalizovat_id_bvs(id_bvs)
if isstring(id_bvs)
    id_bvs = cellstr(id_bvs(:).');
elseif ischar(id_bvs)
    id_bvs = {id_bvs};
elseif ~iscell(id_bvs)
    error('%s', 'Идентификаторы БВС должны быть заданы списком строк.');
end

id_bvs = cellfun(@(znachenie) char(string(znachenie)), ...
    id_bvs, 'UniformOutput', false);

if numel(unique(id_bvs)) ~= numel(id_bvs)
    error('%s', 'Идентификаторы БВС в графе связности должны быть уникальными.');
end
end

function proverit_sostoyaniya_dlya_zvenev(sostoyaniya_bvs, id_bvs)
if ~isstruct(sostoyaniya_bvs) || isempty(sostoyaniya_bvs)
    error('%s', [ ...
        'Для формирования звеньев требуется непустой массив состояний БВС.' ...
        ]);
end

identifikatory_sostoyanii = cell(1, numel(sostoyaniya_bvs));
for nomer_bvs = 1:numel(sostoyaniya_bvs)
    sostoyanie = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));
    identifikatory_sostoyanii{nomer_bvs} = sostoyanie.id_bvs;
end

if numel(unique(identifikatory_sostoyanii)) ~= numel(identifikatory_sostoyanii)
    error('%s', 'Идентификаторы БВС в состояниях должны быть уникальными.');
end

if numel(identifikatory_sostoyanii) ~= numel(id_bvs) ...
        || ~isempty(setxor(identifikatory_sostoyanii, id_bvs))
    error('%s', [ ...
        'Состав состояний БВС не совпадает с составом участников графа ' ...
        'связности.' ...
        ]);
end
end

function komponenty = nayti_svyaznye_komponenty(matrica_smeznosti)
chislo_bvs = size(matrica_smeznosti, 1);
otmecheno = false(1, chislo_bvs);
komponenty = {};

for nachalnyi_indeks = 1:chislo_bvs
    if otmecheno(nachalnyi_indeks)
        continue
    end

    ochered = nachalnyi_indeks;
    otmecheno(nachalnyi_indeks) = true;
    komponenta = [];

    while ~isempty(ochered)
        tekushchii = ochered(1);
        ochered(1) = [];
        komponenta(end + 1) = tekushchii; %#ok<AGROW>

        sosedi = find(matrica_smeznosti(tekushchii, :));
        novye_sosedi = sosedi(~otmecheno(sosedi));
        otmecheno(novye_sosedi) = true;
        ochered = [ochered, novye_sosedi]; %#ok<AGROW>
    end

    komponenty{end + 1} = sort(komponenta); %#ok<AGROW>
end
end

function indeksy_zvenev = razbit_komponentu_na_zvenya(komponenta, matrica_smeznosti, matrica_poleznosti_linii, matrica_rasstoyanii_m, parametry_zvenev)

indeksy_zvenev = {};
ostatok = sort(komponenta(:).');
predel = parametry_zvenev.maksimalnyi_razmer_zvena;

while ~isempty(ostatok)
    if numel(ostatok) <= predel
        tekushchee_zveno = ostatok;
        ostatok = [];
    else
        opornyi_indeks = vybrat_opornyi_bvs( ...
            ostatok, matrica_smeznosti, matrica_poleznosti_linii);
        tekushchee_zveno = opornyi_indeks;
        ostatok(ostatok == opornyi_indeks) = [];

        while numel(tekushchee_zveno) < predel && ~isempty(ostatok)
            kandidaty = ostatok(any( ...
                matrica_smeznosti(ostatok, tekushchee_zveno), 2).');
            if isempty(kandidaty)
                kandidaty = ostatok;
            end

            sleduyushchii_indeks = vybrat_luchshego_kandidata( ...
                tekushchee_zveno, ...
                kandidaty, ...
                matrica_poleznosti_linii, ...
                matrica_rasstoyanii_m);
            tekushchee_zveno(end + 1) = sleduyushchii_indeks; %#ok<AGROW>
            ostatok(ostatok == sleduyushchii_indeks) = [];
        end
    end

    if numel(tekushchee_zveno) == 1 && ~parametry_zvenev.razreshit_odinochnye_zvenya
        error('%s', [ ...
            'Образовалось одиночное звено, хотя параметры звеньев ' ...
            'запрещают такие звенья.' ...
            ]);
    end

    indeksy_zvenev{end + 1} = sort(tekushchee_zveno); %#ok<AGROW>
end
end

function opornyi_indeks = vybrat_opornyi_bvs(ostatok, matrica_smeznosti, matrica_poleznosti_linii)

summa_poleznosti = zeros(1, numel(ostatok));
stepeni = zeros(1, numel(ostatok));

for nomer_kandidata = 1:numel(ostatok)
    indeks = ostatok(nomer_kandidata);
    summa_poleznosti(nomer_kandidata) = sum( ...
        matrica_poleznosti_linii(indeks, ostatok));
    stepeni(nomer_kandidata) = sum(matrica_smeznosti(indeks, ostatok));
end

[~, poryadok] = sortrows([ ...
    -summa_poleznosti(:), ...
    -stepeni(:), ...
    ostatok(:)]);
opornyi_indeks = ostatok(poryadok(1));
end

function luchshii_indeks = vybrat_luchshego_kandidata(tekushchee_zveno, kandidaty, matrica_poleznosti_linii, matrica_rasstoyanii_m)

summa_poleznosti = zeros(1, numel(kandidaty));
minimalnye_rasstoyaniya = inf(1, numel(kandidaty));

for nomer_kandidata = 1:numel(kandidaty)
    kandidat = kandidaty(nomer_kandidata);
    summa_poleznosti(nomer_kandidata) = sum( ...
        matrica_poleznosti_linii(kandidat, tekushchee_zveno));
    minimalnye_rasstoyaniya(nomer_kandidata) = min( ...
        matrica_rasstoyanii_m(kandidat, tekushchee_zveno));
end

[~, poryadok] = sortrows([ ...
    -summa_poleznosti(:), ...
    minimalnye_rasstoyaniya(:), ...
    kandidaty(:)]);
luchshii_indeks = kandidaty(poryadok(1));
end

function rezultat = sobrat_rezultat_zvenev(id_bvs, indeksy_zvenev)
if isempty(indeksy_zvenev)
    error('%s', 'Не удалось сформировать ни одного звена роя.');
end

chislo_bvs = numel(id_bvs);
nomer_zvena_dlya_bvs = zeros(1, chislo_bvs);
zvenya = repmat(struct( ...
    'nomer_zvena', 0, ...
    'id_bvs', {{}}, ...
    'indeksy_bvs', [], ...
    'razmer_zvena', 0), 1, numel(indeksy_zvenev));

for nomer_zvena = 1:numel(indeksy_zvenev)
    indeksy = sort(indeksy_zvenev{nomer_zvena});
    if any(nomer_zvena_dlya_bvs(indeksy) ~= 0)
        error('%s', 'Один и тот же БВС попал более чем в одно звено.');
    end

    nomer_zvena_dlya_bvs(indeksy) = nomer_zvena;
    zvenya(nomer_zvena).nomer_zvena = nomer_zvena;
    zvenya(nomer_zvena).id_bvs = id_bvs(indeksy);
    zvenya(nomer_zvena).indeksy_bvs = indeksy;
    zvenya(nomer_zvena).razmer_zvena = numel(indeksy);
end

if any(nomer_zvena_dlya_bvs == 0)
    error('%s', 'Не все БВС были распределены по звеньям.');
end

razmery = [zvenya.razmer_zvena];

rezultat = struct();
rezultat.id_bvs = id_bvs;
rezultat.zvenya = zvenya;
rezultat.nomer_zvena_dlya_bvs = nomer_zvena_dlya_bvs;
rezultat.chislo_zvenev = numel(zvenya);
rezultat.chislo_odinochnyh_zvenev = sum(razmery == 1);
rezultat.srednii_razmer_zvena = mean(razmery);
rezultat.maksimalnyi_razmer_zvena = max(razmery);
rezultat.primechanie = [ ...
    'Звенья сформированы только по расчетному графу связности без ' ...
    'маршрутизации, управления и изменения траекторий.' ...
    ];
end

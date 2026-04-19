function sostoyaniya_bvs = sozdat_sostoyanie_bvs_iz_scenariya(scenarii)
if nargin < 1 || ~isstruct(scenarii)
    error('%s', 'Для создания состояний БВС требуется структура сценария.');
end

if ~isfield(scenarii, 'sostav_roya')
    error('%s', 'В сценарии отсутствует поле sostav_roya.');
end

if ~isfield(scenarii, 'oblast_poleta')
    error('%s', 'В сценарии отсутствует поле oblast_poleta.');
end

oblast_poleta = proverit_oblast_poleta( ...
    scenarii.oblast_poleta, ...
    'поля oblast_poleta в структуре сценария');
zapisi_bvs = normalizovat_sostav_roya(scenarii.sostav_roya);

sostoyaniya_bvs = repmat(struct( ...
    'id_bvs', '', ...
    'rol', '', ...
    'polozhenie', zeros(1, 3), ...
    'skorost', zeros(1, 3), ...
    'zapas_energii', 0, ...
    'rabotosposoben', true), 1, numel(zapisi_bvs));

for nomer_bvs = 1:numel(zapisi_bvs)
    zapis_bvs = zapisi_bvs{nomer_bvs};
    proverit_pole_bvs(zapis_bvs, 'id_bvs');
    proverit_pole_bvs(zapis_bvs, 'rol');
    proverit_pole_bvs(zapis_bvs, 'nachalnoe_polozhenie');
    proverit_pole_bvs(zapis_bvs, 'nachalnaya_skorost');
    proverit_pole_bvs(zapis_bvs, 'zapas_energii');

    sostoyanie_bvs = struct();
    sostoyanie_bvs.id_bvs = proverit_nepustuyu_stroku( ...
        zapis_bvs.id_bvs, ...
        'id_bvs');
    sostoyanie_bvs.rol = proverit_nepustuyu_stroku( ...
        zapis_bvs.rol, ...
        'rol');
    sostoyanie_bvs.polozhenie = proverit_vektor_iz_treh_komponent( ...
        zapis_bvs.nachalnoe_polozhenie, ...
        'nachalnoe_polozhenie');
    sostoyanie_bvs.skorost = proverit_vektor_iz_treh_komponent( ...
        zapis_bvs.nachalnaya_skorost, ...
        'nachalnaya_skorost');
    sostoyanie_bvs.zapas_energii = proverit_neotricatelnoe_chislo( ...
        zapis_bvs.zapas_energii, ...
        'zapas_energii');
    sostoyanie_bvs.rabotosposoben = true;

    if ~tochka_v_oblasti_poleta(sostoyanie_bvs.polozhenie, oblast_poleta)
        error('%s', sprintf( ...
            'Начальное положение БВС %s находится вне области полета.', ...
            sostoyanie_bvs.id_bvs));
    end

    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyanie_bvs);
end
end

function zapisi_bvs = normalizovat_sostav_roya(sostav_roya)
if ~isstruct(sostav_roya)
    error('%s', 'Поле sostav_roya должно быть массивом записей о БВС.');
end

if isempty(sostav_roya)
    error('%s', 'Состав роя пустой. Требуется хотя бы один БВС.');
end

if isscalar(sostav_roya)
    zapisi_bvs = {sostav_roya};
else
    zapisi_bvs = squeeze(num2cell(sostav_roya));
end
end

function proverit_pole_bvs(zapis_bvs, imya_polya)
if ~isfield(zapis_bvs, imya_polya)
    error('%s', sprintf( ...
        'У записи БВС отсутствует обязательное поле %s.', ...
        imya_polya));
end
end

function znachenie = proverit_nepustuyu_stroku(znachenie, imya_polya)
znachenie = char(string(znachenie));

if strlength(strtrim(string(znachenie))) == 0
    error('%s', sprintf( ...
        'Поле %s должно содержать непустую строку.', ...
        imya_polya));
end
end

function vektor = proverit_vektor_iz_treh_komponent(vektor, imya_polya)
if ~isnumeric(vektor) || ~isvector(vektor) || numel(vektor) ~= 3
    error('%s', sprintf( ...
        'Поле %s должно быть числовым вектором из трех компонент.', ...
        imya_polya));
end

vektor = reshape(double(vektor), 1, 3);
if any(~isfinite(vektor))
    error('%s', sprintf( ...
        'Поле %s должно содержать только конечные числа.', ...
        imya_polya));
end
end

function znachenie = proverit_neotricatelnoe_chislo(znachenie, imya_polya)
if ~isnumeric(znachenie) || ~isscalar(znachenie) || ~isfinite(znachenie)
    error('%s', sprintf( ...
        'Поле %s должно быть конечным числом.', ...
        imya_polya));
end

znachenie = double(znachenie);
if znachenie < 0
    error('%s', sprintf( ...
        'Поле %s не может быть отрицательным.', ...
        imya_polya));
end
end

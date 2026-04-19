function sostoyanie_bvs = proverit_sostoyanie_bvs(sostoyanie_bvs)
if nargin < 1 || ~isstruct(sostoyanie_bvs)
    error('%s', 'Для проверки состояния БВС требуется структура.');
end

obyazatelnye_polya = {
    'id_bvs'
    'rol'
    'polozhenie'
    'skorost'
    'zapas_energii'
    'rabotosposoben'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(sostoyanie_bvs, imya_polya)
        error('%s', sprintf( ...
            'В состоянии БВС отсутствует обязательное поле %s.', ...
            imya_polya));
    end
end

sostoyanie_bvs.id_bvs = proverit_nepustuyu_stroku( ...
    sostoyanie_bvs.id_bvs, ...
    'id_bvs');
sostoyanie_bvs.rol = proverit_nepustuyu_stroku( ...
    sostoyanie_bvs.rol, ...
    'rol');
sostoyanie_bvs.polozhenie = proverit_vektor_iz_treh_komponent( ...
    sostoyanie_bvs.polozhenie, ...
    'polozhenie');
sostoyanie_bvs.skorost = proverit_vektor_iz_treh_komponent( ...
    sostoyanie_bvs.skorost, ...
    'skorost');
sostoyanie_bvs.zapas_energii = proverit_neotricatelnoe_chislo( ...
    sostoyanie_bvs.zapas_energii, ...
    'zapas_energii');
sostoyanie_bvs.rabotosposoben = proverit_logicheskoe_znachenie( ...
    sostoyanie_bvs.rabotosposoben, ...
    'rabotosposoben');
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

function znachenie = proverit_logicheskoe_znachenie(znachenie, imya_polya)
if ~(islogical(znachenie) && isscalar(znachenie))
    error('%s', sprintf( ...
        'Поле %s должно быть логическим значением.', ...
        imya_polya));
end
end

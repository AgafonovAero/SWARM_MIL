function ocheredi_bvs = sozdat_ocheredi_bvs(id_bvs, soobshcheniya, parametry_peredachi)
if nargin < 1
    error('%s', ...
        'Для создания очередей БВС требуется список идентификаторов.');
end

if nargin < 2
    soobshcheniya = struct([]);
end

if nargin < 3 || isempty(parametry_peredachi)
    parametry_peredachi = parametry_peredachi_po_umolchaniyu();
else
    parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);
end

id_bvs = normalizovat_id_bvs(id_bvs);
ocheredi_bvs = repmat(struct( ...
    'id_bvs', '', ...
    'soobshcheniya', {cell(1, 0)}), 1, numel(id_bvs));

for nomer_bvs = 1:numel(id_bvs)
    ocheredi_bvs(nomer_bvs).id_bvs = id_bvs{nomer_bvs};
end

if isempty(soobshcheniya)
    return
end

if ~isstruct(soobshcheniya)
    error('%s', ...
        'Начальные сообщения должны быть переданы массивом структур.');
end

for nomer_soobshcheniya = 1:numel(soobshcheniya)
    [ocheredi_bvs, soobshchenie, dobavleno] = dobavit_soobshchenie_v_ochered( ...
        ocheredi_bvs, ...
        soobshcheniya(nomer_soobshcheniya).id_otpravitelya, ...
        soobshcheniya(nomer_soobshcheniya), ...
        parametry_peredachi);

    if ~dobavleno
        error('%s', sprintf( ...
            'Не удалось добавить начальное сообщение %s в очередь БВС %s.', ...
            soobshchenie.id_soobshcheniya, ...
            soobshchenie.id_otpravitelya));
    end
end
end

function id_bvs = normalizovat_id_bvs(id_bvs)
if isstring(id_bvs)
    id_bvs = cellstr(id_bvs(:).');
elseif ischar(id_bvs)
    id_bvs = {id_bvs};
elseif ~iscell(id_bvs)
    error('%s', ...
        'Идентификаторы БВС должны быть заданы списком строк.');
end

id_bvs = cellfun(@(znachenie) char(string(znachenie)), ...
    id_bvs, ...
    'UniformOutput', false);

if isempty(id_bvs) || numel(unique(id_bvs)) ~= numel(id_bvs)
    error('%s', ...
        'Идентификаторы БВС для создания очередей должны быть непустыми и уникальными.');
end
end

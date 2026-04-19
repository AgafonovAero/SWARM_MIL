function elementy = zapolnit_vkladku_zvenev(vkladka, parametry_zvenev)
if nargin < 2 || ~isstruct(parametry_zvenev)
    error('%s', 'Для заполнения вкладки звеньев требуются параметры звеньев.');
end

maket = uigridlayout(vkladka, [8, 2]);
maket.RowHeight = repmat({30}, 1, 7);
maket.RowHeight{8} = '1x';
maket.ColumnWidth = {280, '1x'};
maket.Padding = [10, 10, 10, 10];

elementy = struct();
elementy.maket = maket;
elementy.minimalnyi_razmer_zvena = sozdat_chislovoe_pole( ...
    maket, 1, 'Минимальный размер звена', ...
    parametry_zvenev.minimalnyi_razmer_zvena);
elementy.maksimalnyi_razmer_zvena = sozdat_chislovoe_pole( ...
    maket, 2, 'Максимальный размер звена', ...
    parametry_zvenev.maksimalnyi_razmer_zvena);
elementy.ves_stepeni_bvs = sozdat_chislovoe_pole( ...
    maket, 3, 'Вес степени БВС', ...
    parametry_zvenev.ves_stepeni_bvs);
elementy.ves_poleznosti_linii = sozdat_chislovoe_pole( ...
    maket, 4, 'Вес полезности линии', ...
    parametry_zvenev.ves_poleznosti_linii);
elementy.ves_centralnosti = sozdat_chislovoe_pole( ...
    maket, 5, 'Вес центральности', ...
    parametry_zvenev.ves_centralnosti);
elementy.ves_zapasa_energii = sozdat_chislovoe_pole( ...
    maket, 6, 'Вес запаса энергии', ...
    parametry_zvenev.ves_zapasa_energii);

nadpis_odin = uilabel(maket);
nadpis_odin.Text = 'Разрешить одиночные звенья';
nadpis_odin.Layout.Row = 7;
nadpis_odin.Layout.Column = 1;

razreshit_odinochnye = uicheckbox(maket);
razreshit_odinochnye.Layout.Row = 7;
razreshit_odinochnye.Layout.Column = 2;
razreshit_odinochnye.Value = logical(parametry_zvenev.razreshit_odinochnye_zvenya);

knopka_po_umolchaniyu = uibutton(maket, 'push');
knopka_po_umolchaniyu.Layout.Row = 8;
knopka_po_umolchaniyu.Layout.Column = [1, 2];
knopka_po_umolchaniyu.Text = 'Вернуть значения по умолчанию';

elementy.razreshit_odinochnye_zvenya = razreshit_odinochnye;
elementy.knopka_po_umolchaniyu = knopka_po_umolchaniyu;
end

function pole = sozdat_chislovoe_pole(maket, nomer_stroki, nadpis, znachenie)
nadpis_pole = uilabel(maket);
nadpis_pole.Text = nadpis;
nadpis_pole.Layout.Row = nomer_stroki;
nadpis_pole.Layout.Column = 1;

pole = uieditfield(maket, 'numeric');
pole.Layout.Row = nomer_stroki;
pole.Layout.Column = 2;
pole.Value = double(znachenie);
end

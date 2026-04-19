function elementy = zapolnit_vkladku_peredachi(vkladka, parametry_peredachi)
if nargin < 2 || ~isstruct(parametry_peredachi)
    error('%s', ...
        'Для заполнения вкладки передачи требуются параметры передачи.');
end

maket = uigridlayout(vkladka, [10, 2]);
maket.RowHeight = repmat({30}, 1, 9);
maket.RowHeight{10} = '1x';
maket.ColumnWidth = {280, '1x'};
maket.Padding = [10, 10, 10, 10];

elementy = struct();
elementy.maket = maket;
elementy.maksimalnyi_razmer_ocheredi = sozdat_chislovoe_pole( ...
    maket, 1, 'Максимальный размер очереди', ...
    parametry_peredachi.maksimalnyi_razmer_ocheredi);
elementy.maksimalnoe_chislo_peresylok = sozdat_chislovoe_pole( ...
    maket, 2, 'Максимальное число пересылок', ...
    parametry_peredachi.maksimalnoe_chislo_peresylok);
elementy.vremya_zhizni_soobshcheniya = sozdat_chislovoe_pole( ...
    maket, 3, 'Время жизни сообщения, с', ...
    parametry_peredachi.vremya_zhizni_soobshcheniya_s);
elementy.bazovyi_razmer_soobshcheniya = sozdat_chislovoe_pole( ...
    maket, 4, 'Базовый размер сообщения, бит', ...
    parametry_peredachi.bazovyi_razmer_soobshcheniya_bit);

nadpis_golovnye = uilabel(maket);
nadpis_golovnye.Text = 'Передача через головные БВС';
nadpis_golovnye.Layout.Row = 5;
nadpis_golovnye.Layout.Column = 1;

propuskat_cherez_golovnye = uicheckbox(maket);
propuskat_cherez_golovnye.Layout.Row = 5;
propuskat_cherez_golovnye.Layout.Column = 2;
propuskat_cherez_golovnye.Value = logical( ...
    parametry_peredachi.propuskat_cherez_golovnye_bvs);

nadpis_pryamaya = uilabel(maket);
nadpis_pryamaya.Text = 'Разрешить прямую передачу';
nadpis_pryamaya.Layout.Row = 6;
nadpis_pryamaya.Layout.Column = 1;

razreshit_pryamuyu = uicheckbox(maket);
razreshit_pryamuyu.Layout.Row = 6;
razreshit_pryamuyu.Layout.Column = 2;
razreshit_pryamuyu.Value = logical( ...
    parametry_peredachi.razreshit_pryamuyu_peredachu);

elementy.ves_zaderzhki = sozdat_chislovoe_pole( ...
    maket, 7, 'Вес задержки', ...
    parametry_peredachi.ves_zaderzhki);
elementy.ves_chisla_peresylok = sozdat_chislovoe_pole( ...
    maket, 8, 'Вес числа пересылок', ...
    parametry_peredachi.ves_chisla_peresylok);
elementy.ves_dostavki = sozdat_chislovoe_pole( ...
    maket, 9, 'Вес доставки', ...
    parametry_peredachi.ves_dostavki);

knopka_po_umolchaniyu = uibutton(maket, 'push');
knopka_po_umolchaniyu.Layout.Row = 10;
knopka_po_umolchaniyu.Layout.Column = [1, 2];
knopka_po_umolchaniyu.Text = 'Вернуть значения по умолчанию';

elementy.propuskat_cherez_golovnye_bvs = propuskat_cherez_golovnye;
elementy.razreshit_pryamuyu_peredachu = razreshit_pryamuyu;
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

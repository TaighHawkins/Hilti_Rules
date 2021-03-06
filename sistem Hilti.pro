%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Sistem Construzioni
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%	Don't forget to update the date when you change the rules!
i_version( sistem, `25 February 2014` ).

i_date_format( _ ).
%i_pdf_parameter( x_tolerance_100, 100 ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	set(reverse_punctuation_in_numbers)
	, get_fixed_variables
	, get_invoice_date
	, get_order_number
	, get_order_date
	, get_delivery_contact
	, get_delivery_number
	, get_buyer_contact

%	you need this to enable the count rule to work correctly
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	, get_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  set( purchase_order )
	
	, agent_code_1(`00`)
	, agent_code_2(`01`)
	, agent_code_3(`7500`)
	, suppliers_code_for_buyer(`13099977`)
	, buyer_registration_number(`IT-ADAPTRI`)
	
	, buyer_party( `LS` )
	, supplier_party(`LS`)
	, supplier_registration_number(`P11_100`)
	, agent_name(`GBADAPTRIS`)
	
	



		

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET BUYER AND DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_delivery_number, [
%=======================================================================

or([

		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `F`, `/`, `CO`, `NS`, `.`, `SEDE`, tab , delivery_note_number(`13099977`)]] )]
		,
		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `F`, `/`, `CO`, `NS`, `.`, dummy(s), tab , delivery_note_number(`13099977`)]] )]
		,
		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `F`, `/`, `CO`, `vs`, `.`, dummy(s), tab , delivery_note_number(`13099977`)]] )]
		,
		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `F`, `/`, `CO`, `NS`, `.`, tab , delivery_note_number(`13099977`)]] )]
		,
		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `C`, `/`, `o`, `ns`, `.`, `sede`, `di`, `Solignano`, dummy(s), tab , delivery_note_number(`13099977`)]] )]
		,
		[q(0,30,line),generic_horizontal_details( [[ `Resa`, tab, `F`, `/`, `CO`, `NS`, `.`, `SEDE`, `DI`, `SOLIGNANO` , delivery_note_number(`13099977`)]] )]
		
		
])
	
] ).

%=======================================================================
i_rule( get_buyer_contact, [
%=======================================================================

	
	q(0,30,line),generic_vertical_details( [ [ `Persona`, `di`, `riferimento` ], buyer_contact, sf, or( [ `tel`, gen_eof ] ) ] )
	
	, q(0,1,line),  generic_horizontal_details( [ buyer_email, s, newline] )
	
	
] ).

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	
	q(0,30,line),generic_vertical_details( [ [ `Persona`, `di`, `riferimento` ], delivery_contact, sf, or( [ `tel`, gen_eof ] ) ] )
	
	, q(0,1,line),  generic_horizontal_details( [ delivery_email, s, newline] )
	
	
] ).


%======================================================================================================
i_rule( get_order_number, [
%======================================================================================================
		 
	q(0,10,line), generic_horizontal_details( [ [ `N`, `°` ], 100, order_number,s, newline ] )
	
]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_rule( get_order_date, [
%======================================================================================================

	q(0,10,line), generic_horizontal_details( [ [`del`, `:` ], invoice_date ,date, tab ] )	
	
	
	
]).

%======================================================================================================
i_rule( get_invoice_date, [
%======================================================================================================
		
		q(0,20,line), generic_horizontal_details( [  [`Your`, `Reference`],150,  date_hook,s1, newline ])
		, q(0,2,line), get_date_thing([invoice_date])
		
		
]).


%======================================================================================================
i_line_rule( get_date_thing( [ Variable ] ), [ nearest( date_hook(start), 30, 30 ), generic_item( [ Variable, date ] ) ] ).
%======================================================================================================




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [`TOTALE`, `NETTO`, `€`] ] )
	
	, q(0,1, line), generic_horizontal_details( [ [`€`], total_net, d, newline ] )

	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [ [ with( invoice, delivery_charge, Charge )
	
			, check( sys_calculate_str_subtract( total_net, Charge, Net_1 ) )
			
			, net_subtotal_2( Charge )
			
			, gross_subtotal_2( Charge )
			
		]
		
		, [ without( delivery_charge )
		
			, check( total_net = Net_1 )
			
		]
		
	] )
	
	, net_subtotal_1( Net_1 )
	
	, gross_subtotal_1( Net_1 )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n( [

		  or( [ 
		
		  line_invoice_rule
			 
		, line

		] )

	] )
		
	, line_end_line

] ).



%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================
	
		`Prodotto`, tab, `Descrizione`, `del`, `Prodotto`, tab, `Consegna`, tab, `UDM`, tab, `Quantità`, tab, `Prezzo`, `Unit`, `.`, tab, `%`, `Sc`, `.`, tab, `Importo`,  newline
 
		, trace([`found header`])
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================


		or([
		
		[`Prego`, `inviare`, `fattura`, `in`, `formato`, `elettronico`, `all`, `’`, `indirizzo`, `mail`, `:`, `fornitori`, `@`, `pec`, `.`, `sistem`, `.`, `it`,  newline]
		
		,
			
		[`Condizioni`, `di`, `pagamento`, tab, `RICEVUTA`, `BANCARIA`, `120`, `GG`, `FM`, `con`, `scadenza`, `al`, `10`, `del`, `mese`, `successivo`, `.`,  newline]
		
		,
			
		[`Persona`, `di`, `riferimento`, tab, `Timbro`, `e`, `firma`, `per`, `Accettazione`,  newline]
		
		])

] ).

%=======================================================================
i_line_rule_cut( line_invoice_rule, [
%=======================================================================

		
		or([
		
		[line_item_for_buyer(s), tab, line_descr(s)
		
		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s), tab, line_descr(s)
		
		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, check( line_item_for_buyer(end) < -372 )

		
		, line_descr(s)

		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, tab

		
		, line_descr(s)
		
		, tab

		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,[
		line_descr(s)
		
		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_descr(s)

		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[ line_descr(s)
		
		, tab

		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, tab

		
		, line_descr(s)
		
		, tab

		
		, line_item( f( [ begin, q(dec,4,10), end ] ) )
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), line_percent_discount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s), tab, line_descr(s)
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s), tab, line_descr(s)
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, check( line_item_for_buyer(end) < -372 )

		
		, line_descr(s)

		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, tab

		
		, line_descr(s)
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), line_percent_discount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_item_for_buyer(s)

		, tab

		
		, line_descr(s)
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,[
		line_descr(s)
		
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[line_descr(s)

		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		,
		
		[ line_descr(s)
		
		, tab, line_original_order_date(date), tab, line_quantity_uom_code(s), tab, line_quantity(d), tab, dummy(w), line_unit_amount(d), tab, dummy(w), net_amount(d), newline
		
		, count_rule]
		
		])
		
		
		
		
] ).


%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).


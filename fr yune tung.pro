%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - YUNE TUNG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( yune_tung, `30 April 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

% i_pdf_parameter( same_line, 6 ).
i_pdf_parameter( x_tolerance_100, 100 ).

i_user_field( invoice, buyer_location, `Buyer Location` ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables 

	, get_order_number
	
	, get_invoice_date
	
	, get_deliv_ref
	
	, set(reverse_punctuation_in_numbers)
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )
	
	, get_invoice_lines
	
	, get_invoice_totals
	
	, clear(reverse_punctuation_in_numbers)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [
%=======================================================================

	set(reverse_punctuation_in_numbers)

	, buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `FR-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`01`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0900`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10558391` ) ]    %TEST
	    , suppliers_code_for_buyer( `11624891` )                      %PROD
	]) ]
	
	, buyer_dept(`0014250583`)
	, delivery_from_contact(`0014250583`)
	
	, type_of_supply( `F5` )
		
	, sender_name( `Yune Tung S.A.` )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ q0n(line), get_order_number_line ] ).
%=======================================================================
i_line_rule( get_order_number_line, [ 
%=======================================================================

	`COMMANDE`, `N`, `°`, `:`
	
	, generic_item( [ order_number, s1, newline ] )
	
	, set( leave_spaces_in_order_number )


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_date, [ q0n(line), get_invoice_date_line ] ).
%=======================================================================
i_line_rule( get_invoice_date_line, [ 
%=======================================================================

	`Du`, `:`
	
	, generic_item( [ invoice_date, date, newline ] )


] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_deliv_ref, [
%=======================================================================

	set(delivery_note_ref_no_failure) 

	, or( [ 
	
		[ check( q_sys_sub_string( SUBJECT, _, _, `VINCI` ) ), delivery_note_referencex(`20255291`) ]
		
		, [ check( q_sys_sub_string( SUBJECT, _, _, `LEON GROSSE` ) ), delivery_note_referencex(`21032482`) ]
		
		, [ check( q_sys_sub_string( SUBJECT, _, _, `INEO` ) ), delivery_note_referencex(`22135393`) ]
		
		, [ delivery_note_referencex(`11624891`) ]
		
	] )
	
	, check( delivery_note_referencex = DRef)
	
	, trace( [ DRef ] )
	
	, check( strcat_list( [ `FRYUNE`, DRef ], DRef1 ) )
	
	, delivery_note_reference(DRef1)

] )
:- 
	i_mail(subject, Subject),
	string_to_upper(Subject, SUBJECT)
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, q0n(

		or( [ line_invoice_rule
		
			, line_check_line
		
			, line

		] )

	), line_end_line
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `!`, `Référence`, `Fourn`, `.`, `!`, tab, `Désignation`, header(w) ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================
	
	or( [ 
	
		[ `Transitaire` ]
		
		, [ `!`, tab, `!`, tab, `!`, tab, `!`, tab, `!`, tab, `!`,  newline ] 

		, [ dummy(s1), check( header(page) \= dummy(page) ) ]
		
	] )

] ).



%=======================================================================
i_line_rule_cut( line_check_line, [ 
%=======================================================================
	
	q0n(anything), `|`, a(s1), q10(tab), `|`, a(d), tab, q10(b(w)), `|`
	
	, force_result(`defect`), force_sub_result(`missied_line`)

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	line_invoice_line
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	`|` 
	
	,or( [ 
	
		[ generic_item_cut( [ line_item, s1 ] ) ]
		
		, [ set( need_line_item ) ]
		
	] ), tab
	
	, `|`
	
	, q10( [ test(need_line_item), read_ahead( [ q0n(word), line_item( f( [ begin, q(dec, 5, 8), end ] ) ) ] ) ] )
	
	, or( [ 
	
		[ generic_item( [ line_descr, s1 ] ), tab ]
		
		, [ generic_item( [ line_descr, sf ] ) ]
		
		, [ generic_item( [ line_descr, s1 ] ), tab, q10( append(line_descr(sf), ` `, ``) ), q10( tab ) ] 
		
		, [ generic_item( [ line_descr, s1 ] ), tab, q10( append(line_descr(sf), ` `, ``) ), tab, q10( append(line_descr(sf), ` `, ``) ), q10( tab ) ] 		
		
	] ), clear(need_line_item) 
	
	, `|`, tab
	
	, generic_item( [ line_quantity, d, q10(tab) ] )
	
	, or( [

		[ `BT`, line_quantity_uom_code(`PAK`), trace( [ `Setting UoM as PAK` ] ) ]
		
		, [ q10( generic_item( [ dummy, w ] ) ), line_quantity_uom_code(`EA`), trace( [ `Setting UoM as EA` ] ) ]
		
	] )
	
	, trace( [ `Entering Unit Amount` ] ), `|`, trace( [ `Entering Unit Amount1` ] ), tab, q10( generic_item( [ line_unit_amountx, d ] ) )

	, `|`, tab, q10( generic_item( [ line_net_amount, d ] ) )
	
	, `|`, newline
	
	, trace( [ `Line Finished` ] )
	
] ).

%=======================================================================
i_rule_cut( get_invoice_totals, [
%=======================================================================

	or( [ 
	
		[ q0n(line), generic_horizontal_details( [ [ `Eur`, tab ], total_net, d, newline ] )
			, with(invoice, total_net, Net), total_invoice(Net)
		]
		
		, [ total_net(`0`), total_invoice(`0`) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).

i_analyse_line_fields_first(LID):-i_multiply_values(LID).
i_multiply_values(LID)
:-
	result(_,LID,line_quantity_uom_code,UOM),
	UOM=`PAK`,
	result(_,LID,line_quantity, Quantity),
	result(_,LID,line_descr,Descr),
	string_to_upper(Descr, DescrU),
	string_string_replace(DescrU, `/`, ` / `, DescrRep),
	sys_string_split(DescrRep, ` `, DescrList),
	q_sys_member(BT, [ `BTE`, `BOITE`, `BT` ] ),
	sys_append(_,[BT, `/`, Num | _ ], DescrList),
	sys_calculate_str_multiply(Num, Quantity, NewQuantity),
	sys_retract( result(_,LID,line_quantity, Quantity) ),
	sys_retract( result(_,LID,line_quantity_uom_code,UOM) ),
	assertz_derived_data(LID, line_quantity, NewQuantity, i_multiply_values),
	assertz_derived_data(LID, line_quantity_uom_code, `EA`, i_multiply_values),
	!
.
	
	
	
	
	
	
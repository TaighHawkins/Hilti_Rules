%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - ES ESTAMPACIONES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( es_estampaciones, `31 July 2015` ).

i_date_format( _ ).

i_pdf_parameter( space, 2 ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	get_fixed_variables
	
	, get_order_number

	, gen_capture( [ [ gen_beof, `Fecha`, `:` ], invoice_date, date, newline ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines
	
	, get_invoice_lines1
	
	, get_invoice_totals

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIXED VARIABLES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_fixed_variables, [ 
%=======================================================================

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `ES-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`7000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `Estampaciones Metálicas Épila, S.A.` )
	
	, set( reverse_punctuation_in_numbers )
	
	, or( [
		[ test( test_flag ), suppliers_code_for_buyer( `10558391` ) ]
		, suppliers_code_for_buyer( `13674850` )
	] )

	, delivery_note_reference( `FREMESA05707246` )
	, buyer_dept( `FREMESA05707246` )
	, delivery_from_contact( `FREMESA05707246` )
	
	, set( delivery_note_ref_no_failure )

] ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, or( [
	
		[ line_invoice_rule, line_end_line ]
	
		, [ force_result( `defect` ), force_sub_result( `missed_line` ), trace( [ `missed line` ] ) ]
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Cantidad`, `Unid`, `.`, `Código`, tab, `Descripción`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Cantidad`, `Unid`, `.`, `Código`, tab, `Descripción` ]
		
		, [ `Conforme`, `:` ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line

	, line_descr_append
	
	, line
	
	, line_date_line
	
	, q01(line)
	
	, generic_horizontal_details( [ [ `Total`, `linea`, `:` ], line_net_amount, d, newline ] )
	
	, total_net_add_rule
	
	, count_rule
	
	, clear( need_item )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, w, q10(tab) ] )
	
	, generic_item( [ line_item_for_buyer, w, q10(tab) ] )
	
	, or( [
	
		read_ahead( [ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,8), end ], `)` ] ) ] )
		
		, set( need_item )
		
	] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, generic_no( [ cantidad, d ] )
	
	, word, tab
	
	, generic_no( [ line_unit_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_append, [
%=======================================================================

	  or( [
	
		[ test( need_item ), read_ahead( [ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,8), end ], `)` ] ) ] )
			, append( line_descr(s1), ` `, `` ), tab
		]
		
		, peek_fails( test( need_item ) )
		
	] )
	
	, `Precio`, `en`, `ud`, `:`, tab
	
	, generic_no( [ unit_amount, d, newline ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_date_line, [
%=======================================================================

	  `E`, `.`, `T`, `.`, `C`, `.`, `:`, q10( a(s1) ), tab
	
	, `Plazo`, `:`
		
	, generic_item( [ line_original_order_date, date, newline ] )
	
	, q10( [ 
	
		without(delivery_date)
		
		, with(invoice, line_original_order_date, ODate)
		
		, delivery_date(ODate)
		
		, trace( [ delivery_date ] ) 
		
	] )
	
] ).

%=======================================================================
i_rule_cut( total_net_add_rule, [
%=======================================================================

	  or( [
	
		[ with( invoice, total_net, Net ), check( sys_calculate_str_add( Net, line_net_amount, Total ) ) ]
		
		, check( line_net_amount = Total )
		
	] )
	
	, total_net( Total ), trace( [ `new total`, Total ] )
	
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines1, [
%=======================================================================

	line_header_line1

	, q0n( or( [
	
		[ line_invoice_rule1 ]
	
		, [ line_check_line ]
		
		, [ line ] 
		
	] ) ), line_end_line1

] ).

%=======================================================================
i_line_rule_cut( line_header_line1, [
%=======================================================================

	`Código`, tab, `Descripción`, tab, `Cantidad`

] ).

%=======================================================================
i_line_rule_cut( line_end_line1, [
%=======================================================================

	`Condiciones`, `de`, `pago`, `:`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule1, [
%=======================================================================

	  line_invoice_line1

	, q10(line_descr_append1)
	
	, total_net_add_rule
	
	, clear( need_item )
	
	, count_rule
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line1, [
%=======================================================================

	generic_no( [ line_item_for_buyer, d, q10(tab) ] )
	
	, or( [
	
		read_ahead( [ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,8), end ], `)` ] ) ] )
		
		, set( need_item )
		
	] )
	
	, or( [ 

		[ generic_item( [ line_descr, s1, tab ] ) ]
		
		, [ generic_item( [ line_descr, sf ] ) ]
		
	] )

	, generic_item( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, w, tab ] )
	
	, generic_item( [ line_unit_amount, d ] )
	
	, q0n(word), tab
	
	, generic_no( [ line_net_amount, d, [ `€`, tab ] ] )
	
	, q0n(word), q10(tab)
	
	, generic_item( [ line_original_order_date, date, newline ] )
	
	, q10( [ 
	
		without(delivery_date)
		
		, with(invoice, line_original_order_date, ODate)
		
		, delivery_date(ODate)
		
		, trace( [ delivery_date ] ) 
		
	] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_append1, [
%=======================================================================

	  or( [
	
		[ test( need_item ), read_ahead( [ q0n(word), `(`, generic_item( [ line_item, [ begin, q(dec,4,8), end ], `)` ] ) ] )
			, append( line_descr(s1), ` `, `` ), newline
		]
		
		, peek_fails( test( need_item ) )
		
	] )
	
] ).

%=======================================================================
i_line_rule_cut( line_check_line, [ 
%=======================================================================
	
	q0n(anything), `Plazo`, `:`, q10(tab), a(date), newline
	
	, force_result(`defect`), force_sub_result(`missied_line`)

] ).



%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [
%=======================================================================

	q0n(line)
	
	, or( [ 
	
		[ order_number_line ] 
		
		, [ order_number_line(2, -150, 150) ]
		
	] )

] ).

%=======================================================================
i_line_rule( order_number_line, [
%=======================================================================

	q0n(anything)
	
	, `Nº`, `de`, `Pedido`, `:`, q10(tab)
	
	, generic_item( [ order_number, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_invoice_totals, [
%=======================================================================

	  with( invoice, total_net, Net ), total_invoice( Net ), trace( [ `total_invoice`, total_invoice ] )

] ).
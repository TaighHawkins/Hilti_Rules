%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT AUER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_auer, `19 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, get_buyer_contact

	, get_buyer_ddi

	, get_buyer_email

	, get_order_date
	
	, get_due_date
	
	, get_order_number

	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	,[ qn0(line), invoice_total_line]
	

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

%	, buyer_registration_number( `shipping` )
	
	, supplier_party( `LS` )

	, buyer_registration_number( `AT-ADAPTRI` )

	, supplier_registration_number( `P11_100` )

	, type_of_supply(`S0`)

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0001`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10041345` ) ]    %TEST
	    , suppliers_code_for_buyer( `10040957` )                      %PROD
	]) ]

	, [ or([ 
	  [ test(test_flag), delivery_note_number( `10041345` ) ]    %TEST
	    , delivery_note_number( `10040957` )                      %PROD
	]) ]


] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Ansprechpartner`, `:` ], names, s1 ] )
	  
	, check( i_user_check( sort_names, names, Con ) )
	
	, buyer_contact( Con )

] ).

%=======================================================================
i_user_check( sort_names, Names, Con )
%-----------------------------------------------------------------------
:-
%=======================================================================
	sys_string_split( Names, ` `, Name_List ),
	sys_reverse( Name_List, [ First_Name | Rev_Surnames ] ),
	sys_reverse( Rev_Surnames, Surname_List ),	
	sys_stringlist_concat( Surname_List, ` `, Surnames ),
	strcat_list( [ First_Name, ` `, Surnames ], Con )
.

%=======================================================================
i_rule( get_buyer_ddi, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ `Telefon`, `:` ], 150, ddi_x, s1, newline ] )
	
	, check( ddi_x = DDI_x )
	
	, check( strip_string2_from_string1( DDI_x, `./() -`, DDI  ) )
	
	, buyer_ddi( DDI )

] ).

%=======================================================================
i_rule( get_buyer_email, [ 
%=======================================================================

	q(0,15,line), generic_horizontal_details( [ [ `E`, `-`, `Mail`, `:` ], 150, buyer_email, s1, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORDER NUMBER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_order_number, [ 
%=======================================================================

	  q(0,15,line), generic_horizontal_details( [ [ `BESTELLUNG` ], order_number, s1 ] )

] ).

%=======================================================================
i_rule( get_order_date, [ 
%=======================================================================

	  q(0,10,line), generic_horizontal_details( [ [ `Bestelldatum`, `:` ], invoice_date, date ] )

] ).

%=======================================================================
i_rule( get_due_date, [ 
%=======================================================================

	  q0n(line), generic_horizontal_details( [ [ `Liefertermin`, `:` ], due_date, date ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_total_line, [
%=======================================================================

	`Gesamtpreis`, `EUR`, `:`, tab

	, read_ahead(total_invoice(d))

	, total_net(d)

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	 line_header_line

	, qn0( [ peek_fails(line_end_line)

		, or( [ line_invoice_rule
		
			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Pos`, `.`, tab, `Menge`] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamptpreis`, `EUR` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_values_line

	, line_descr_line
	
	, q01( line_continuation_line )
	
	, line_item_line
	
	, with( invoice, due_date, Date )
	
	, line_original_order_date( Date )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, d, tab ] )
	  
	, generic_item( [ line_quantity, d ] )
	
	, generic_item_cut( [ line_quantity_uom_code, w, q10( tab ) ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_unit_amount, d, tab ] )
	
	, generic_item( [ line_net_amount, d, newline ] )

] ).

%=======================================================================
i_line_rule_cut( line_descr_line, [ generic_item( [ line_descr, s1, newline ] ) ] ).
%=======================================================================
i_line_rule_cut( line_continuation_line, [ append( line_descr(s1), ` `, `` ), newline ] ).
%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	  `Art`, `-`, `Nr`, `:`
	
	, generic_item( [ line_item, [ begin, q(dec,4,8), end ] ] )

] ).


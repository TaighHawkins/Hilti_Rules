%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - BE COLRUYT GROUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( be_colruyt_group, `09 June 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).

i_user_field( invoice, packing_instructions, `Packing Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `ONZE`, `REFERENTIE`, `:` ], order_number, s1, tab ] )
	, gen_capture( [ [ `ONZE`, `REFERENTIE`, `:`, a(s1) ], invoice_date, date, newline ] )

	, get_delivery_details
	
	, gen_capture( [ [ `'`, `BESTELLER`, `:` ], buyer_contact, s1, tab ] )
	, gen_capture( [ [ `'`, `BESTELLER`, `:` ], delivery_contact, s1, tab ] )
	
	, gen_capture( [ [ `GELIEVE`, `ONDERSTAANDE`, `BESTELLING`, `EXACT`, `TE`, `LEVEREN`, `OP`, `:` ], due_date, date, newline ] )
	
	, check( i_user_check( gen_cntr_set, 20, 0 ) )

	, get_invoice_lines

	, gen_capture( [ [ `TOTAAL`, `EXCL`, `BTW`, `IN`, `EUR`, q10(tab), `:`, tab ], total_net, d, newline ] )
	, gen_capture( [ [ `TOTAAL`, `EXCL`, `BTW`, `IN`, `EUR`, q10(tab), `:`, tab ], total_invoice, d, newline ] )
	
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

	, buyer_registration_number( `BE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`0700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10086426` ) ]    %TEST
	    , suppliers_code_for_buyer( `10058313` )                      %PROD
	]) ]
	
	, sender_name( `Colruyt Group` )
	
	, picking_instructions( `Nur am Freitag Liefern` )
	, packing_instructions( `Nur am Freitag Liefern` )

	, set( reverse_punctuation_in_numbers )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================

	  q(0,50,line)
	
	, generic_line( [ `LEVERINGSADRES` ] )

	, generic_line( [ [ `-`, `-`, `-`, `-`, `-` ] ] )
	
	, delivery_thing( [ delivery_party ] )
	
	, delivery_thing( [ delivery_address_line ] )
	
	, delivery_street_line
	
	, delivery_postcode_city_line

] ).

%=======================================================================
i_line_rule( delivery_thing( [ Variable ] ), [
%=======================================================================

	  generic_item( [ Variable, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_street_line, [
%=======================================================================

	  generic_item( [ delivery_street, s1, tab ] ), append( delivery_street(d), ` `, `` )

] ).

%=======================================================================
i_line_rule( delivery_postcode_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,4,5), end ], tab ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	, q0n( or( [ line_invoice_rule, line ] ) )

	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `ARTIKEL`, tab, `AANTAL`, `EENH`

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  `TOTAAL`, `EXCL`, `BTW`

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_horizontal_details( [ [ `UW`, `/`, `REF` ], line_item, w, newline ] )
	
	, count_rule

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_item( [ line_item_for_buyer, w ] )
	
	, generic_item( [ line_descr, s1, tab ] )
	
	, line_quantity(d), generic_item( [ line_quantity_uom_code, s1, tab ] )

	, generic_item( [ line_unit_amount, d, newline ] )

	, with( invoice, due_date, Date ), line_original_order_date(Date)

] ).

%=======================================================================
i_rule_cut( count_rule, [
%=======================================================================

	  check( i_user_check( gen_cntr_get, 20, LINE_NUMBER ) )
	, check(i_user_check(gen_add, LINE_NUMBER, 10, NEXT_LINE_NUMBER) )
	, check( i_user_check( gen_cntr_set, 20, NEXT_LINE_NUMBER ) )
	, line_order_line_number(NEXT_LINE_NUMBER)

] ).
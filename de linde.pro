%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE LINDE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_linde, `10 March 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, gen_vert_capture( [ [ `Belegnummer`, tab, `Datum` ], order_number, s1, tab ] )
	, gen_vert_capture( [ [ tab, `Datum`, q10( [ tab, `Liefertermin` ] ), newline ], invoice_date, date ] )
	
	, get_suppliers_code_for_buyer
	
	, get_delivery_details

	, get_buyer_and_delivery_contact_details
	
	, gen_capture( [ [ `interne`, `Referenz`, `:` ], 400, shipping_instructions, s1, [ prepend( shipping_instructions( `interne Referenz: ` ), ``, `` ) ] ] )

	, get_delivery_date
	
	, get_invoice_lines

	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `:`, `EUR` ], 600, total_net, d, newline ] )
	, gen_capture( [ [ `Gesamtnettowert`, `ohne`, `Mwst`, `:`, `EUR` ], 600, total_invoice, d, newline ] )

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

	, buyer_registration_number( `DE-ADAPTRI` )

	, or( [ 
		[ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Linde AG` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPLIERS CODE FOR BUYER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_suppliers_code_for_buyer, [ 
%=======================================================================

	  q(0,25,line)
	
	, generic_line( [ [ `Lieferanschrift`, `:`, tab, `Rechnungsversandanschrift`, `:` ] ] )
	
	, or( [
	
		[ generic_horizontal_details( [ [ `Linde`, `AG`, `,`, `Linde`, `Gas`, `Deutschland` ] ] )
			, or( [ 
				[ test(test_flag), suppliers_code_for_buyer( `11204927` ) ]    %TEST
				, suppliers_code_for_buyer( `18089166` )                      %PROD
			] )
		]
		
		, [ generic_horizontal_details( [ [ `Linde`, `Gas`, `Produktionsgesellschaft`, `mbh`, `&`, `Co`, `.`, `KG` ] ] )
			, or( [
				[ test(test_flag), suppliers_code_for_buyer( `10116449` ) ]    %TEST
				, suppliers_code_for_buyer( `18089169` )                      %PROD
			] )
		]
		
	] )
	
	, trace( [ `suppliers_code_for_buyer`, suppliers_code_for_buyer ] )

] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_details, [ 
%=======================================================================
	  
	  q(0,25,line)
	
	, generic_line( [ [ `Lieferanschrift`, `:`, tab, `Rechnungsversandanschrift`, `:` ] ] )
	
	, q10( generic_line( [ `Firma` ] ) )
	
	, delivery_thing( [ delivery_party ] )
	
	, q10( [ delivery_thing( [ delivery_dept ] )
	
		, q10( delivery_thing( [ delivery_address_line ] ) )
		
	] )

	, delivery_thing( [ delivery_street ] )
	
	, delivery_postcode_and_city_line
	
] ).

%=======================================================================
i_line_rule( delivery_thing( [ Var ] ), [
%=======================================================================

	  generic_item( [ Var, s1 ] )
	
] ).

%=======================================================================
i_line_rule( delivery_postcode_and_city_line, [
%=======================================================================

	  generic_item( [ delivery_postcode, [ begin, q(dec,5,5), end ] ] )
	
	, generic_item( [ delivery_city, s1 ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER AND DELIVERY CONTACT DETAILS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact_details, [ 
%=======================================================================

	  q(0,25,line)
	  
	, q10( [ generic_horizontal_details( [ [ or( [ `Phone`, [ `Tel`, `.` ] ] ), `:` ], buyer_ddi_x, s1, newline ] )
	
		, check( strip_string2_from_string1( buyer_ddi_x, ` -`, DDI ) )
		, buyer_ddi( DDI )
		, delivery_ddi( DDI )
		
	] )
		
	, q10( [ generic_horizontal_details( [ [ `Fax`, `:` ], buyer_fax_x, s1, newline ] )
		
		, check( strip_string2_from_string1( buyer_fax_x, ` -`, Fax ) )
		, buyer_fax( Fax )
		, delivery_fax( Fax )
		
	] )
	
	, generic_horizontal_details( [ [ or( [ `Email`, [ `E`, `-`, `Mail` ] ] ), `:` ], buyer_email, s1, newline ] )
	
	, check( i_user_check( get_contact_from_email, buyer_email, Contact ) )
	
	, buyer_contact(Contact), trace( [ `buyer_contact`, buyer_contact ] )
	
	, check( buyer_email = Email )
	, delivery_email( Email )
	
	, delivery_contact( Contact )

] ).

%-----------------------------------------------------------------------
i_user_check( get_contact_from_email, EMAIL_IN, CONTACT_OUT )
%-----------------------------------------------------------------------
:-
	sys_string_split( EMAIL_IN, `@`, [ Name, Domain ] ),
	string_string_replace( Name, `.`, ` `, CONTACT_OUT )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_delivery_date, [
%=======================================================================

	  q(0,25,line), generic_horizontal_details( [ [ `Liefertermin`, newline ] ] )
	
	, delivery_date_line

] ).

%=======================================================================
i_line_rule( delivery_date_line, [
%=======================================================================

	  nearest( generic_hook(start), 10, 10 )
	
	, `Tag`, generic_item( [ delivery_date, date, newline ] )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section_control( get_invoice_lines, first_one_only ).
%=======================================================================
i_section_end( get_invoice_lines, line_end_section_line ).
%=======================================================================
i_line_rule_cut( line_end_section_line, [ `Belegnummer`, tab, `Datum`, newline ] ).
%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( or( [ line_invoice_rule, line ] ) )
	
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Bezeichnung`, tab, `EUR`, tab, `EUR` ] ).
%=======================================================================
i_line_rule_cut( line_end_line, [ `Gesamtnettowert`, `ohne`, `Mwst` ] ).
%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_number_and_quantity_line
	
	, q10(line)
	
	, or( [
	
		liefertermin_line
		
		, [ with( invoice, delivery_date, Date ), line_original_order_date(Date) ]
		
	] )

	, generic_horizontal_details( [ [ `Ihre`, `Materialnummer`, `:` ], 400, line_item, s1, newline ] )
	
	, q10( generic_horizontal_details( [ at_start, line_descr, s1, newline ] ) )
	
	, q(0,5,line), line_values_line
	
] ).

%=======================================================================
i_line_rule_cut( line_number_and_quantity_line, [
%=======================================================================

	  generic_item( [ line_order_line_number, [ begin, q(dec,5,5), end ], q10(tab) ] )
	
	, q01( generic_item( [ line_item_for_buyer, s1, tab ] ) )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, w, newline ] )

] ).

%=======================================================================
i_line_rule_cut( liefertermin_line, [
%=======================================================================

	  `Liefertermin`, `:`

	, or( [

		[ peek_fails( test( liefertermin ) ), with( invoice, delivery_date, Date ), line_original_order_date(Date) ]
		
		, [ q10( [ without( delivery_date )
				, read_ahead( generic_item( [ delivery_date, date ] ) )
				, set( liefertermin )
			] )
			, generic_item( [ line_original_order_date, date, newline ] )
		]

	] )

] ).

%=======================================================================
i_line_rule_cut( line_values_line, [ 
%=======================================================================

	  `Bruttopreis`, tab
	
	, generic_no( [ something, d ] )
	, generic_item( [ something, w, tab ] )
	
	, generic_no( [ line_unit_amount_x, d, tab ] )
	
	, generic_no( [ line_net_amount, d, newline ] )
	
] ).

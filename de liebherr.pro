%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - DE LIEBHERR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( de_liebherr, `23 June 2015` ).

i_date_format( _ ).
i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables
	  
	, gen_vert_capture( [ [ `Bestell`, `-`, `Nr`, `.` ], order_number, s1, tab ] )
	, gen_vert_capture( [ [ `Datum`, tab, `Lieferant` ], invoice_date, date, tab ] )

	, get_buyer_and_delivery_contact
	
	, gen_vert_capture( [ [ `Hausapparat`, tab, `Ihr` ], buyer_ddi, s1, prepend( buyer_ddi( `03816006` ), ``, `` ) ] )
	, gen_vert_capture( [ [ `Hausapparat`, tab, `Ihr` ], delivery_ddi, s1, prepend( delivery_ddi( `03816006` ), ``, `` ) ] )
	
	, gen_vert_capture( [ [ `Fax`, `-`, `Nr`, `.`, tab, `Hausapparat` ], buyer_fax, s1, prepend( buyer_fax( `03816006` ), ``, `` ) ] )
	, gen_vert_capture( [ [ `Fax`, `-`, `Nr`, `.`, tab, `Hausapparat` ], delivery_fax, s1, prepend( delivery_fax( `03816006` ), ``, `` ) ] )
	
	, gen_capture( [ [ gen_beof, `email`, `:` ], buyer_email, s1 ] )
	, gen_capture( [ [ gen_beof, `email`, `:` ], delivery_email, s1 ] )
	
	, get_invoice_lines

	, gen_capture( [ [ `Summe`, `:` ], 200, total_net, d ] )
	, gen_capture( [ [ `Summe`, `:` ], 200, total_invoice, d ] )

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

	, or( [
		[ test(test_flag), suppliers_code_for_buyer( `10126965` ) ]    %TEST
	    , suppliers_code_for_buyer( `11453629` )                      %PROD
	] )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`5000`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)
	
	, set( reverse_punctuation_in_numbers )
	
	, sender_name( `Liebherr-MCCtec Rostock GmbH` )
	
	, delivery_note_number( `11453629` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER AND DELIVERY CONTACT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_and_delivery_contact, [ 
%=======================================================================

	  q(0,25,line)
	  
	, generic_vertical_details( [ [ `Sachbearbeiter`, tab, `Bestell` ], contact, s1, tab ] )
	
	, check( i_user_check( clean_up_contact, contact, Contact ) )
	
	, buyer_contact( Contact )
	, delivery_contact( Contact )
	, trace( [ `buyer_contact`, buyer_contact ] )
	, trace( [ `delivery_contact`, delivery_contact ] )

] ).

%-----------------------------------------------------------------------
i_user_check( clean_up_contact, Contact_in, CONTACT_OUT )
%-----------------------------------------------------------------------
:-
	string_to_lower( Contact_in, Contact_l ),
	sys_string_split( Contact_l, ` `, List ),
	capitalise_first_letters( List, ``, CONTACT_OUT )
.

capitalise_first_letters( [ H | T ], Input, Contact_out )
:-
	q_sys_sub_string( H, 1, 1, First_letter ),
	q_sys_sub_string( H, 2, _, The_rest ),
	string_to_upper( First_letter, Letter_U ),
	
	(
		Input = ``,
		strcat_list( [ Letter_U, The_rest ], Name )
		
		;
		
		strcat_list( [ Input, ` `, Letter_U, The_rest ], Name )

	),
	
	(
		T = [ ],
		Name = Contact_out
		
		;
		
		capitalise_first_letters( T, Name, Contact_out )
		
	),
	
	!
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line
	 
	, trace( [ `found header` ] )

	, q0n( or( [ line_invoice_rule, line ] ) )
	
	, line_end_line

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `Termin`, newline

] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Summe`, `:` ]
		
		, [ `1`, test( got_1_already ) ]
		
	] )

] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, generic_line( [ [ generic_item( [ line_descr, s1, tab ] ), generic_item( [ a, date ] ) ] ] )
	
	, q10( read_ahead( generic_horizontal_details( [ [ `Netto`, `:` ], 200, line_net_amount, d, [ `EUR`, `/`, a(s1), newline ] ] ) ) )
	
	, q01(line)
	
	, generic_horizontal_details( [ [ or( [ `Art`, `Arrt` ] ), `.`, `-`, `Nr`, `.` ], line_item, [ begin, q(dec,4,10), end ] ] )
	
] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  q10( [ read_ahead( `1` ), set( got_1_already ) ] )
	
	, generic_no( [ line_order_line_number, d, q10(tab) ] )
	
	, generic_item( [ artikel_code_, s1, tab ] )
	
	, generic_item( [ not_the_line_descr_, s1, tab ] )
	
	, generic_no( [ line_quantity, d ] )
	
	, generic_item( [ line_quantity_uom_code, s1, tab ] )
	
	, generic_no( [ line_unit_amount, d ] )
	
	, `EUR`, `/`, generic_item( [ einheit_, s1, newline ] )
	
] ).
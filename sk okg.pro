%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SK OKG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( sk_okg, `15 July 2015` ).

i_date_format( 'd mon y' ).
i_date_language( swedish ).

i_correlate_amounts_total_to_use( total_net, net_subtotal_1).
i_correlate_amounts_total_to_use( total_invoice, gross_subtotal_1).

i_user_field( invoice, delivery_charge, `Delivery Charge` ).
i_user_field( invoice, delivery_district, `Delivery District` ).
i_user_field( invoice, type_of_supply, `Type of Supply` ).

i_orders05_idocs_e1edkt1( `Z011`, picking_instructions ).
i_user_field( invoice, picking_instructions, `Picking Instructions` ).
i_orders05_idocs_e1edkt1( `Z012`, packing_instructions ).
i_user_field( invoice, packing_instructions, `Packing Instructions` ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	set( reverse_punctuation_in_numbers )

	, get_fixed_variables

	, [ q0n(line), generic_horizontal_details( [ [ `Beställningsnr`, `.` ], order_number, s1, newline ] ) ]

	, [ q0n(line), generic_horizontal_details( [ [ `Vår`, `referens`, `:`,  newline ] ] ), q(0,2,line), buyer_contact_line, q(0,2,line), buyer_email_line ]

	, [ q0n(line), or( [ generic_horizontal_details( [ [ `Beställning` ] ] ), invoice_date_line ] ) ]

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

	  buyer_party( `LS` )

	, supplier_party( `LS` )

	, buyer_registration_number( `SE-ADAPTRI` )

	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                      %PROD
	]) ]

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2600`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, sender_name( `OKG` )
	
	, delivery_note_number( `20980403` )

	, suppliers_code_for_buyer( `11312704` )

] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_contact_line, [
%=======================================================================

	q0n(anything)

	, lower_buyer_contact(s1)

	, check( lower_buyer_contact(start) > 200 )

	, newline

	, check( string_to_upper( lower_buyer_contact, BC ) )

	, buyer_contact( BC )

	, trace( [ `buyer_contact`, buyer_contact ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( buyer_email_line, [
%=======================================================================

	q0n(anything)

	, buyer_email(s1)

	, check( buyer_email(start) > 200 )

	, check( q_valid_email(buyer_email) )

	, newline

	, trace( [ `buyer_email`, buyer_email ] )
] ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_line_rule( invoice_date_line, [
%=======================================================================

	invoice_date(d)

	, check( invoice_date(start) < -350 )

	, `.`

	, append( invoice_date(s1), ` `, `` )

	, trace( [ `invoice_date`, invoice_date ] )
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BUYER CONTACT AND EMAIL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_buyer_contact_and_email, [
%=======================================================================

	  buyer_email(From), trace( [ `buyer_email`, buyer_email ] )
	
	, buyer_contact(Contact), trace( [ `buyer_contact`, buyer_contact ] )
	
] )
:-
	i_mail( from, From ),
	sys_string_split( From, `@`, [ Name, Domain ] ),
	string_to_upper( Domain, DOMAIN ),
	DOMAIN \= `HILTI.COM`,
	string_string_replace( Name, `.`, ` `, Contact )
.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE TOTALS	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_rule( get_totals, [
%=======================================================================

	  q0n(line)
	  
	, generic_horizontal_details( [ [ `Totalt`, `nettovärde`, `:`, tab, set( regexp_cross_word_boundaries ) ], total_net, d, newline ] )

	, clear( regexp_cross_word_boundaries )
	, check( total_net = Net )
	
	, total_invoice( Net )
	
	, or( [
	
		[ with( invoice, delivery_charge, Charge )
	
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=======================================================================
i_section( get_invoice_lines, [
%=======================================================================

	  line_header_line

	  , qn0( or( [ position_line, quantity_line, line_item_line, [ peek_fails( total_line ), peek_fails( line_header_line ), line ] ] ) )
] ).

%=======================================================================
i_line_rule_cut( line_header_line, [ `Orderkvantitet`, tab, `Enhet`, tab, `Pris`, `per`, `enhet`, tab, `Nettovärde`, newline ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( total_line, [ `Totalt`, `nettovärde`, `:`, tab ] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( position_line, [
%=======================================================================

	generic_item( [ line_order_line_number, d ] )

	, check( line_order_line_number(start) < -350 )

	, check( line_order_line_number(start) > -400 )

	, tab

	, dumm1(s1)

	, tab

	, dummy2(s1)

	, newline
] ).

%=======================================================================
i_line_rule_cut( quantity_line, [
%=======================================================================

	line_quantity(d)

	, check( line_quantity(start) < -200 )

	, check( line_quantity(start) > -250 )

	, tab

	, line_quantity_uom_code(s1)

	, q0n(anything)

	, tab

	, set( regexp_cross_word_boundaries )

	, line_net_amount(d)

	, newline

	, trace( [ `quantity, uom and net`, line_quantity, line_quantity_uom_code, line_net_amount ] )

	, clear( regexp_cross_word_boundaries )

] ).

%=======================================================================
i_line_rule_cut( line_item_line, [
%=======================================================================

	read_ahead( fred(s1) ),

	q0n( anything )

	, `Lev`, `artnr`, `:`

	, generic_item( [ line_item, d ] )
] ).

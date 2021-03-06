%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - Bane Danmark
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( banedk, `24 March 2014` ).

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
	, get_buyer_ddi
	, get_buyer_email
	, get_delivery
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
	
	, set(purchase_order )
	
	,  [ or([ 
	  [ test(test_flag), suppliers_code_for_buyer( `10550149` ) ]    %TEST
	    , suppliers_code_for_buyer( `11272553` )  				               %PROD
	]) ]
	
	
	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`2700`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)	
	

	, buyer_registration_number(`DK-ADAPTRI`)
	
	%	They have the Q01 and P11 systems - Q for test, P for live
	, [ or([ 
	  [ test(test_flag), supplier_registration_number( `Q01_100` ) ]    %TEST
	    , supplier_registration_number( `P11_100` )                    %PROD
	]) ]

	, set( no_total_validation ) %	Use this when the totals can't be trusted
	
] ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DELIVERY ADDRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_rule( get_delivery, [
%======================================================================================================

	q(0,20,line), generic_horizontal_details( [ [`Fakturaadresse`, `:`, tab, read_ahead([ `Vareadresse`, `:`]) ], delivery_hook,s1 ] )
	
	, q(0,2,line),  get_delivery_thing( [ dummy])
	
	, q(0,2,line),  get_delivery_thing( [ delivery_party])
	
	, q(0,2,line),  read_ahead(get_delivery_thing( [shipping_instructions])), get_delivery_thing( [customer_comments])

	, q(0,2,line),  get_delivery_thing( [ delivery_street])
	
	, get_delivery_PC
	
	

]).


%======================================================================================================
i_line_rule( get_delivery_PC, [
%======================================================================================================

	nearest(delivery_hook(start), 10, 10 ),  generic_item( [delivery_postcode, d]),  generic_item( [delivery_city, s1])


]).


%======================================================================================================
i_line_rule( get_delivery_thing( [ Variable ] ), [ nearest( delivery_hook(start), 20, 20 ), generic_item( [ Variable, s1 ] ) ] ).
%======================================================================================================


%=======================================================================
i_rule( get_delivery_number, [
%=======================================================================


	q(0,30,line),generic_horizontal_details( [ [ `Vor`, `rek`,  `:`, dummy(s), `mob`, `.`, `:`], delivery_ddi, s1, newline] ) 

		
	
] ).

%=======================================================================
i_rule( get_delivery_contact, [
%=======================================================================

	
	q(0,30,line),generic_horizontal_details( [ [ `Vor`, `rek`,  `:`], delivery_contact, s, `mob`] ) 
	
	, q(0,1,line),  generic_horizontal_details( [ [`Mail`, `vor`, `rek`, `:`],delivery_email, s, newline] )
	
	
] ).


%======================================================================================================
i_rule( get_order_number, [
%======================================================================================================
		 
	q(0,10,line), generic_horizontal_details( [ [ `Indkøbsordre`, `nr`, `:`], order_number,s, newline ] )
	
]).


%======================================================================================================
i_rule( get_buyer_contact, [
%======================================================================================================
		 
	q(0,50,line), generic_horizontal_details( [ [ `Økonomi`], 200, buyer_contact,s, tab ] )
	
]).

%======================================================================================================
i_rule( get_buyer_ddi, [
%======================================================================================================
		 
	q(0,50,line), generic_horizontal_details( [ [ `Vasbygade`, `10`], 200, buyer_ddi,s,tab ] )
	
]).

%======================================================================================================
i_rule( get_buyer_email, [
%======================================================================================================
		 
	q(0,50,line), generic_horizontal_details( [ [ `Vasbygade`, `10`, tab, dummy(s) ], 350, buyer_email,s, newline ] )
	
]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INVOICE DATES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%======================================================================================================
i_rule( get_invoice_date, [
%======================================================================================================

	q(0,10,line), generic_horizontal_details( [ [q0n(anything), `Dato`, `:` ], 200, invoice_date ,date, newline] )	
	
	
	
]).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TOTALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%=======================================================================
i_rule( get_totals, [
%=======================================================================

%	Should have a way of filling in '0' if the totals don't exist.
	  q0n(line)
	  
	,or([

		[generic_horizontal_details( [ [`Samlet`, `nettopris`, `excl`, `.`, `moms`, `DKK`],300, total_net,d, newline  ] )]
		
		,
		
		[generic_horizontal_details( [ [`Med`, `venlig`, `hilsen`,  newline]]) , total_net(`0`) ]
		
		])
	
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
%	No validation
%	Should have a line that can cause a failure
%	I would suggest adding a 'line_defect_line'
%	q0n(anything), some(date), force_result( `defect` ), force_sub_result( `missed_line` )
%
%	All lines contain dates. If you fail the capture, and this succeeds it should fail it.

	 line_header_line

	, q0n( [

		  or( [ 
		
		
		line_header_line_2
		
		, line_header_line_3

		, line_invoice_rule_1
		
		, line_invoice_rule_2
		
		, line_invoice_rule_3
		
		, line_invoice_rule_4
		  
		  , line_contiunation_line
		  
		  , line_defect_line
			 
		, line

		] )

	] )
		
	, line_end_line

] ).




%=======================================================================
i_line_rule_cut( line_defect_line, [ 
%=======================================================================


	q0n(anything), some(date), force_result( `defect` ), force_sub_result( `missed_line` )


]).

%=======================================================================
i_line_rule_cut( line_header_line_2, [ 
%=======================================================================


	`Varespecifikation`, tab, `excl`, `.`, `moms`,  newline


]).

%=======================================================================
i_line_rule_cut( line_header_line_3, [ 
%=======================================================================


	`.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`, `.`,  newline


]).

%	Should have a newline
%=======================================================================
i_line_rule_cut( line_contiunation_line, [ append( line_descr(s1), ` `, ``), newline] ).
%=======================================================================

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================
	
		`Pos`, `.`, `nr`, `.`, `Antal`, `enheder`, tab, `Varenummer`, tab, `Netto`, `pris`, `/`, `enhed`, tab, `Leveringsdato`,  newline
 
		, trace([`found header`])
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [ 
%=======================================================================


		or([
		
			[`Med`, `venlig`, `hilsen`,  newline]
			
			,
			
			[`Spørgsmål`, `om`, `E`, `-`, `faktura`, `,`, `se`, `venligst`, `www`, `.`, `bane`, `.`, `dk`, `-`, `Erhverv`, `-`, `Leverandør`, `.`,  newline]
			
			,
			
			[`Samlet`, `nettopris`, `excl`, `.`, `moms`, `DKK`, tab, dummy(d),  newline]
			
		])

] ).

%=======================================================================
i_rule_cut( line_invoice_rule_1, [
%=======================================================================

		invoice_line_1a
		, q(0, 2, line),  invoice_line_1b
		
				
		
] ).

%=======================================================================
i_line_rule_cut( invoice_line_1a, [
%=======================================================================


	line_order_line_number(d), tab, line_quantity(d), line_quantity_uom_code(w), tab, line_original_order_date(date), newline


]).
%=======================================================================
i_line_rule_cut( invoice_line_1b, [
%=======================================================================
			
			
			line_item( f( [ begin, q(dec,4,10), end ] ) ), line_descr(s), newline



]).

%=======================================================================
i_rule_cut( line_invoice_rule_2, [
%=======================================================================

		invoice_line_1a
		, q(0, 2, line),  invoice_line_2b
		
				
		
] ).


%=======================================================================
i_line_rule_cut( invoice_line_2b, [
%=======================================================================
			
			
		line_descr(s), `(`,  line_item( f( [ begin, q(dec,4,10), end ] ) ),`)`,  newline



]).

%=======================================================================
i_rule_cut( line_invoice_rule_3, [
%=======================================================================

		invoice_line_3a
		, q(0, 6, line),  invoice_line_3b
		
				
		
] ).

%=======================================================================
i_line_rule_cut( invoice_line_3a, [
%=======================================================================


	line_order_line_number(d), tab, line_quantity(d), line_quantity_uom_code(w), tab, line_net_amount(d), `pr`, `.`, tab, dummy(s), tab, line_original_order_date(date), newline


]).

%=======================================================================
i_line_rule_cut( invoice_line_3b, [
%=======================================================================


	line_descr(s),  line_item( f( [ begin, q(dec,4,10), end ] ) ),  newline


]).


%=======================================================================
i_rule_cut( line_invoice_rule_4, [
%=======================================================================

		invoice_line_3a
		, q(0, 2, line),  invoice_line_1b
		
				
		
] ).





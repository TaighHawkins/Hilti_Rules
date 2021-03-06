%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - AT FILL GESELLSCHAFT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( at_fill_gesellschaft, `17 March 2015` ).

i_date_format( _ ).

i_format_postcode( X, X ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	  get_fixed_variables

	, gen_capture( [ [ `Bestellung`, `Nr`, `.`, `:` ], order_number, s1 ] )
	, gen_capture( [ [ gen_beof, `Datum`, `:` ], invoice_date, date, newline ] )
	
	, gen_capture( [ [ `Einkauf`, `:` ], delivery_contact, s1, newline ] )
	, gen_capture( [ [ `Einkauf`, `:` ], buyer_contact, s1, newline ] )
	
	, gen_capture( [ [ `E`, `-`, `Mail`, `:` ], delivery_email, s1, newline ] )
	, gen_capture( [ [ `E`, `-`, `Mail`, `:` ], buyer_email, s1, newline ] )
	
	, gen_capture( [ [ `Liefertermin`, `:` ], due_date, date ] )
	
	, get_invoice_lines
	
	, gen_capture( [ [ gen_beof, `Nettowarenwert` ], total_net, d, newline ] )
	, gen_capture( [ [ gen_beof, `Nettowarenwert` ], total_invoice, d, newline ] )

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
	
	, suppliers_code_for_buyer( `10023005` )

	, sender_name( `Fill Gesellschaft mbH` )
	
	, delivery_note_reference( `ATFILLGURTEN` )
	
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

	, qn0( [ peek_fails( line_end_line )

		, or( [ line_invoice_rule

			, line

		] )

	] )

] ).

%=======================================================================
i_line_rule_cut( line_header_line, [
%=======================================================================

	  `UTNr`, tab, `Bezeichnung`, tab, `eintreffend`, tab, `EUR`
	
] ).

%=======================================================================
i_line_rule_cut( line_end_line, [
%=======================================================================

	  or( [
	
		[ `Nettowarenwert`, tab ]
		
		, [ `Seite`, a(d), `von`, a(d) ]
		
	] )
	
] ).

%=======================================================================
i_rule_cut( line_invoice_rule, [
%=======================================================================

	  line_invoice_line
	
	, or( [
		
		[ generic_line( [ [ `-`, a(d), `%`, tab ] ] )
			, generic_horizontal_details( [ at_start, line_net_amount, d, newline ] )
		]
		
		, [ check( line_net_amount_x = Net ), line_net_amount(Net), trace( [ `line_net_amount`, line_net_amount ] ) ]
		
	] )
	
	, generic_horizontal_details( [ at_start, line_descr, s1, newline ] )
	
	, q10(line)
	
	, generic_horizontal_details( [ [ at_start, q0n(word), peek_fails(tab) ], line_item, [ begin, q(dec,4,10), end ] ] )
	
	, read_ahead( or( [
	
			generic_line( [ [ a(d), tab, a(d) ] ] )
			
			, line_end_line
			
	] ) )

] ).

%=======================================================================
i_line_rule_cut( line_invoice_line, [
%=======================================================================

	  generic_no( [ line_order_line_number, d, tab ] )
	
	, generic_item( [ line_quantity, [ begin, q(dec,1,3), end, q(other(","),1,1), q(dec,2,2) ] ] )
	
	, generic_item( [ line_quantity_uom_code, w ] )
	
	, generic_item( [ line_item_for_buyer, s1, tab ] )
	
	, generic_item( [ line_original_order_date, date, tab ] )
	
	, generic_no( [ line_unit_amount_x, d, tab ] )
	
	, a(d), word, tab
	
	, generic_no( [ line_net_amount_x, d, newline ] )

] ).
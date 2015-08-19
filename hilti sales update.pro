%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - SPEEDY FOR HILTI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( rail_update_rules, `15 Frb 2015` ).

i_pdf_parameter( max_pages, 3 ).

i_date_format( _ ).

i_op_param( email_decision, _, _, _, email ). 
%i_op_param( addr( _ ), FROM, _, _, FROM ). 
i_op_param( addr( _ ), _, _, _, `andy.fardon@hilti.com` ). 
i_op_param( o_mail_subject, _, _, _, `Sales update response` ).

i_op_param( o_mail, _, _, _, sales_update_text ).

sales_update_text :- writeln_proc_file_predicate( o_mail( text, `The attached sales updated has been recorded` ) ).

i_op_param( send_original( _ ), _, _, _, true ).
i_op_param( send_original_name, _, _, _, NAME ):- i_mail(attachment, NAME ).
i_op_param( send_result( _ ), _, _, _, false ).
i_op_param( send_image( _ ), _, _, _, false ).
i_op_param( send_pdf_image( _ ), _, _, _, false ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_rule_list( [
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


	set_header_values

	, set( delivery_note_ref_no_failure )

	, get_new_sales_totals

	, get_update_line([ 0 ])
	, get_update_line([ 1 ])
	, get_update_line([ 2 ])
	, get_update_line([ 3 ])
	, get_update_line([ 4 ])
	, get_update_line([ 5 ])
	, get_update_line([ 6 ])
	, get_update_line([ 7 ])
	, get_update_line([ 8 ])
	, get_update_line([ 9 ])

] ).



%=======================================================================
i_rule( set_header_values, [ 
%=======================================================================

	currency( `4400` )

	, agent_name(`GBADAPTRIS`)
	, agent_code_3(`4400`)
	, agent_code_2(`01`)
	, agent_code_1(`00`)

	, delivery_note_number(``)
	, delivery_note_reference(``)
	, delivery_party(``)
	, delivery_location(``)
	, delivery_city(``)
	, delivery_postcode(``)

]).


%=======================================================================
i_rule( get_new_sales_totals, [ 
%=======================================================================

	q0n(line)

	, territory_id_header_line

	, q(0,3, line)

	, qn1( sales_update_line )


] ).



%=======================================================================
i_line_rule( sales_update_line, [ 
%=======================================================================

	location(w), tab

 	, check( string_string_replace( location, `4400/`, ``,  LOCATION  ) )

	, am(s1), tab

	, q10(`£`)

	, new_value(d)

	, newline

	, check(i_user_check( write_cache_amount, `rail`, LOCATION, new_value ))

	, trace([ `new value`, LOCATION, new_value ])

	, force_result(`defect`), force_sub_result( `sales_update` ) 


] ).

%=======================================================================
i_line_rule( territory_id_header_line, [ `territory`, `id` ]).
%=======================================================================
i_line_rule( territory_header_line, [ `territory`, newline ]).
%=======================================================================
i_line_rule( sales_header_line, [ `sales`, newline ]).
%=======================================================================
i_line_rule( sales_header_line, [ `territory`, tab, `sales`, newline ]).
%=======================================================================


%=======================================================================
i_rule( get_update_line([ I ]), [ 
%=======================================================================

	q0n(line)

	, territory_id_header_line 

	, q( I, I, line )

	, territory_id_line([ LOCATION ])

	, q0n(line)

	, sales_header_line 

	, q( I, I, line )

	, sales_line([ NEW_VALUE ])

	, check(i_user_check( write_cache_amount, `rail`, LOCATION, NEW_VALUE ))

	, trace([ `new value`, LOCATION, NEW_VALUE ])

	, force_result(`defect`), force_sub_result( `sales_update` ) 

] ).



%=======================================================================
i_line_rule( territory_id_line([ ID ]), [ 
%=======================================================================

	q0n(anything), id(s1)
 	, check( string_string_replace( id, `4400/`, ``,  ID  ) )
	, check( q_sys_sub_string( ID, 1, 3, `TGB` ) )
]).


%=======================================================================
i_line_rule( sales_line([ SALES ]), [ 
%=======================================================================

	q0n(anything), sales(s1), newline 
 	, check( string_string_replace( sales, `£`, ``,  SALES  ) )

]).


%=======================================================================
i_user_check( write_cache_amount, LOOKUP, LOCATION, VALUE )
:-
	set_cache(`hilti_sales`, LOOKUP, LOCATION, `amount`, VALUE )

	, save_cache
.
%=======================================================================



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRAMATICA - RULES FOR "DUPLICATE" PROCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i_version( p_hilti_duplicate_rules, `06 February 2015` ).

failed( _, duplicate_order ).

i_op_param( o_mail_subject, _, _, SubIn, SubOut )
:-
	( grammar_set( duplicate ); data( duplicate, `true` ) ),
	strcat_list( [ `Duplicate (NOT PROCESSED): `, SubIn ], SubOut )
.


%	Enabled for: (charge for any requests not on the list)
%	US & CA
%	GB
%	FI
%===============================================================================
i_analyse_fields_last :- i_analyse_duplicate_invoice.
%===============================================================================

%===============================================================================
i_analyse_duplicate_invoice
%-------------------------------------------------------------------------------
:- 
%===============================================================================

	( process_status( Res, _, E_MSG );	result( _, invoice, force_result, Res ) ),
	q_sys_member( Res, [ failed, defect ] ),
	
	!, trace( [ `analyse for duplicate fields ignored because of defect `, E_MSG ] )
.

%===============================================================================
i_analyse_duplicate_invoice
%-------------------------------------------------------------------------------
:-
%===============================================================================

	grammar_set( enable_duplicate_check ),
	
	create_order_table_if_necessary,

	( 	
		result( _, invoice, agent_code_3, Agent3 ),
		
		( result( _, invoice, suppliers_code_for_buyer, SenderID )

			;	result( _, invoice, buyers_code_for_buyer, SenderID )
		),
		!,

		result( _, invoice, order_number, Order ),
	
		(	q_gratabase_lookup( `hilti_order`, [ `general`, SenderID, Order, Agent3 ], [ _, _, _, _ ], Available )

			->	( q_sys_comp( Available = false )
		       	
					-> trace( [ `hilti_order check, database disappeared` ] )

					;
					
					(	q_allow_duplicate_emails,
					
						trace( `ALERT - Order would have failed - allow duplicate emails enabled - Check bypassed` )

						;
						
						wordcat( [ `Duplicate order rejected:`, SenderID, Order, Agent3 ], E_MSG )

						, add_invoice_error( duplicate_order, E_MSG )

						, trace( E_MSG )
						
						, sys_assertz( grammar_set( duplicate ) )
					)

				)

			; add_to_order_table( SenderID, Order, Agent3 )
		)
	
 		;
	
		trace( [ `analyse for duplicate fields ignored because of lack of fields: ` ] ),

		( result( _, invoice, suppliers_code_for_buyer, _ )
			;  result( _, invoice, buyers_code_for_buyer, _ )
			; trace( [ `missing sending_organisation` ] ) 
		),

		( result( _, invoice, order_number, _ ) ; trace( [ `missing order_number` ] ) ),

		( result( _, invoice, agent_code_3, _ ) ; trace( [ `missing agent_code_3` ] ) )

	),

	!
.

%===============================================================================
create_order_table_if_necessary
%-------------------------------------------------------------------------------
:-
%===============================================================================

	q_gratabase_lookup( `hilti_order`, [ _, _, _, _ ], [ _, _, _, _ ], Available )

	, ( q_sys_comp( Available = false )

		->	( q_gratabase_create_table( 4, GUID )

				-> ( q_gratabase_allocate( GUID, `hilti_order` ) 
						
						; 	strcat_list( [ `failed to allocated on creation `, `hilti_order`, ` table` ], Trace ),
							trace( [ Trace ] )
					)

				; strcat_list( [ `failed to create `, `hilti_order`, ` table` ], Trace ),
					trace( [ Trace ] )
			)

		;	true

	)
.

%===============================================================================
add_to_order_table( SenderID, Order, Agent3 )
%-------------------------------------------------------------------------------
:- 
%===============================================================================

	( q_gratabase_clone_table( `hilti_order`, GUID )
			
		-> ( q_gratabase_add( GUID, [ `general`, SenderID, Order, Agent3 ] )
		
			->	trace( [ `added`, SenderID, Order, Agent3 , `to `, `hilti_order`, ` table` ] )

				, ( q_gratabase_allocate( GUID, `hilti_order` )
					
					;	strcat_list( [ `failed to allocate `, `hilti_order`, ` table` ], Trace ),
						trace( [ Trace ] ) 
				)

			;	strcat_list( [ `failed to add row to `, `hilti_order`, ` table` ], Trace ),
				trace( [ Trace ] )
		)

		; strcat_list( [ `failed to clone `, `hilti_order`, ` table` ], Trace ),
			trace( [ Trace ] )
	)
.


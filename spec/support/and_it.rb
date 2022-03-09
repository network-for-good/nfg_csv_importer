# Like 'by' and 'and_by', this allows for easier context in our specs
# For assertions within a workflow that really are 'it', but you don't
# want to start a new it statement, particularly in a feature spec.
#
# example:
# it 'delivers a thing' do
#   by 'doing this thing'
#   and_by 'doing another thing'
#   and_it 'delivers the thing to the user' do
#     expect(page).to have_css 'that-confirms-this-assertion'
#   end
# end

def and_it(message)
  if block_given?
    yield
  else
    pending message
  end
end

alias and_context and_it

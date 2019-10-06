import 'package:invoiceninja_flutter/data/models/group_model.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/company/company_actions.dart';
import 'package:invoiceninja_flutter/redux/ui/entity_ui_state.dart';
import 'package:invoiceninja_flutter/redux/ui/list_ui_state.dart';
import 'package:invoiceninja_flutter/redux/group/group_actions.dart';
import 'package:invoiceninja_flutter/redux/group/group_state.dart';

EntityUIState groupUIReducer(GroupUIState state, dynamic action) {
  return state.rebuild((b) => b
    ..listUIState.replace(groupListReducer(state.listUIState, action))
    ..editing.replace(editingReducer(state.editing, action))
    ..selectedId = selectedIdReducer(state.selectedId, action));
}

Reducer<String> selectedIdReducer = combineReducers([
  TypedReducer<String, ViewGroup>(
      (String selectedId, dynamic action) => action.groupId),
  TypedReducer<String, AddGroupSuccess>(
      (String selectedId, dynamic action) => action.group.id),
  TypedReducer<String, FilterGroupsByEntity>(
      (selectedId, action) => action.entityId == null ? selectedId : 0)
]);

final editingReducer = combineReducers<GroupEntity>([
  TypedReducer<GroupEntity, SaveGroupSuccess>(_updateEditing),
  TypedReducer<GroupEntity, AddGroupSuccess>(_updateEditing),
  TypedReducer<GroupEntity, RestoreGroupSuccess>(_updateEditing),
  TypedReducer<GroupEntity, ArchiveGroupSuccess>(_updateEditing),
  TypedReducer<GroupEntity, DeleteGroupSuccess>(_updateEditing),
  TypedReducer<GroupEntity, EditGroup>(_updateEditing),
  TypedReducer<GroupEntity, UpdateGroup>((group, action) {
    return action.group.rebuild((b) => b..isChanged = true);
  }),
  TypedReducer<GroupEntity, SelectCompany>(_clearEditing),
]);

GroupEntity _clearEditing(GroupEntity group, dynamic action) {
  return GroupEntity();
}

GroupEntity _updateEditing(GroupEntity group, dynamic action) {
  return action.group;
}

final groupListReducer = combineReducers<ListUIState>([
  TypedReducer<ListUIState, SortGroups>(_sortGroups),
  TypedReducer<ListUIState, FilterGroupsByState>(_filterGroupsByState),
  TypedReducer<ListUIState, FilterGroups>(_filterGroups),
  TypedReducer<ListUIState, FilterGroupsByCustom1>(_filterGroupsByCustom1),
  TypedReducer<ListUIState, FilterGroupsByCustom2>(_filterGroupsByCustom2),
  TypedReducer<ListUIState, FilterGroupsByEntity>(_filterGroupsByClient),
]);

ListUIState _filterGroupsByClient(
    ListUIState groupListState, FilterGroupsByEntity action) {
  return groupListState.rebuild((b) => b
    ..filterEntityId = action.entityId
    ..filterEntityType = action.entityType);
}

ListUIState _filterGroupsByCustom1(
    ListUIState groupListState, FilterGroupsByCustom1 action) {
  if (groupListState.custom1Filters.contains(action.value)) {
    return groupListState
        .rebuild((b) => b..custom1Filters.remove(action.value));
  } else {
    return groupListState.rebuild((b) => b..custom1Filters.add(action.value));
  }
}

ListUIState _filterGroupsByCustom2(
    ListUIState groupListState, FilterGroupsByCustom2 action) {
  if (groupListState.custom2Filters.contains(action.value)) {
    return groupListState
        .rebuild((b) => b..custom2Filters.remove(action.value));
  } else {
    return groupListState.rebuild((b) => b..custom2Filters.add(action.value));
  }
}

ListUIState _filterGroupsByState(
    ListUIState groupListState, FilterGroupsByState action) {
  if (groupListState.stateFilters.contains(action.state)) {
    return groupListState.rebuild((b) => b..stateFilters.remove(action.state));
  } else {
    return groupListState.rebuild((b) => b..stateFilters.add(action.state));
  }
}

ListUIState _filterGroups(ListUIState groupListState, FilterGroups action) {
  return groupListState.rebuild((b) => b
    ..filter = action.filter
    ..filterClearedAt = action.filter == null
        ? DateTime.now().millisecondsSinceEpoch
        : groupListState.filterClearedAt);
}

ListUIState _sortGroups(ListUIState groupListState, SortGroups action) {
  return groupListState.rebuild((b) => b
    ..sortAscending = b.sortField != action.field || !b.sortAscending
    ..sortField = action.field);
}

final groupsReducer = combineReducers<GroupState>([
  TypedReducer<GroupState, SaveGroupSuccess>(_updateGroup),
  TypedReducer<GroupState, AddGroupSuccess>(_addGroup),
  TypedReducer<GroupState, LoadGroupsSuccess>(_setLoadedGroups),
  TypedReducer<GroupState, LoadGroupSuccess>(_setLoadedGroup),
  TypedReducer<GroupState, ArchiveGroupRequest>(_archiveGroupRequest),
  TypedReducer<GroupState, ArchiveGroupSuccess>(_archiveGroupSuccess),
  TypedReducer<GroupState, ArchiveGroupFailure>(_archiveGroupFailure),
  TypedReducer<GroupState, DeleteGroupRequest>(_deleteGroupRequest),
  TypedReducer<GroupState, DeleteGroupSuccess>(_deleteGroupSuccess),
  TypedReducer<GroupState, DeleteGroupFailure>(_deleteGroupFailure),
  TypedReducer<GroupState, RestoreGroupRequest>(_restoreGroupRequest),
  TypedReducer<GroupState, RestoreGroupSuccess>(_restoreGroupSuccess),
  TypedReducer<GroupState, RestoreGroupFailure>(_restoreGroupFailure),
]);

GroupState _archiveGroupRequest(
    GroupState groupState, ArchiveGroupRequest action) {
  final group = groupState.map[action.groupId]
      .rebuild((b) => b..archivedAt = DateTime.now().millisecondsSinceEpoch);

  return groupState.rebuild((b) => b..map[action.groupId] = group);
}

GroupState _archiveGroupSuccess(
    GroupState groupState, ArchiveGroupSuccess action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _archiveGroupFailure(
    GroupState groupState, ArchiveGroupFailure action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _deleteGroupRequest(
    GroupState groupState, DeleteGroupRequest action) {
  final group = groupState.map[action.groupId].rebuild((b) => b
    ..archivedAt = DateTime.now().millisecondsSinceEpoch
    ..isDeleted = true);

  return groupState.rebuild((b) => b..map[action.groupId] = group);
}

GroupState _deleteGroupSuccess(
    GroupState groupState, DeleteGroupSuccess action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _deleteGroupFailure(
    GroupState groupState, DeleteGroupFailure action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _restoreGroupRequest(
    GroupState groupState, RestoreGroupRequest action) {
  final group = groupState.map[action.groupId].rebuild((b) => b
    ..archivedAt = null
    ..isDeleted = false);
  return groupState.rebuild((b) => b..map[action.groupId] = group);
}

GroupState _restoreGroupSuccess(
    GroupState groupState, RestoreGroupSuccess action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _restoreGroupFailure(
    GroupState groupState, RestoreGroupFailure action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _addGroup(GroupState groupState, AddGroupSuccess action) {
  return groupState.rebuild((b) => b
    ..map[action.group.id] = action.group
    ..list.add(action.group.id));
}

GroupState _updateGroup(GroupState groupState, SaveGroupSuccess action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _setLoadedGroup(GroupState groupState, LoadGroupSuccess action) {
  return groupState.rebuild((b) => b..map[action.group.id] = action.group);
}

GroupState _setLoadedGroups(GroupState groupState, LoadGroupsSuccess action) {
  final state = groupState.rebuild((b) => b
    ..lastUpdated = DateTime.now().millisecondsSinceEpoch
    ..map.addAll(Map.fromIterable(
      action.groups,
      key: (dynamic item) => item.id,
      value: (dynamic item) => item,
    )));

  return state.rebuild((b) => b..list.replace(state.map.keys));
}